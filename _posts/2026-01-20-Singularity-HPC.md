---
title: 'Creating Reproducible Sandbox Environments for HPC with Singularity'
tags: [Computer]
status: publish
type: post
published: true

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: false
header:
  overlay_image: /assets/images/blog/docker_singularity.png
  overlay_filter: rgba(0,0,0,0.8)
  teaser: /assets/images/blog/docker_singularity.png
classes:
  - wide

permalink: /blog/:year/:month/:day/:title

excerpt: I walk through how I create a container image for use on the HPC, mainly as a note to myself.
---

## Motivations

Many of us neuroscientists perform analyses on large datasets that benefit from parallelization using GPUs. To give a few examples, one might run machine learning based pose-tracking software such as [DeepLabCut] and [SLEAP] to extract positions of animals from hours of video recordings. Or, one might also have extracellular recordings of these animals and would like to extract spike timings of individual cells using spike-sorting softwares such as [Kilosort].

While one can always run these analysis on our local machines, a GPU is not cheap (usually in hundreds of dollars. I still think the ROI is very good though.), and one can also into a memory issue when the process requires accumulation of data (e.g. I had issues running Kilosort on >5hr recordings using 128 channels silicone probes). In these cases, running the processes on a high performing clusters (HPC) would be an attractive option if you have an access to one.

However, every institution configures its HPC differently. Some clusters allow you to freely create virtual environments (e.g., conda environments where you can install packages with conda or pip). Others, like the one I use daily, do not provide that flexibility. We were instructed to contact the HPC management team whenever we needed to install something or create a virtual environment. Often there was a delay before they responded or took action (if they responded at all). But as researchers, we would not spend time waiting for someone else to push a button.


## What is a container

A great workaround in such a scenario is to create a container image. A container image is a self-contained, portable package that includes everything you need to run your workflow: code, libraries, dependencies, system tools, and even parts of the operating system. Once you have a container image for your process (e.g., spike-sorting with Kilosort), you can run the image (i.e. create a sandbox) where you do the computation you want to do and destroy that image once done.

## Docker vs Singularity

If you’ve heard about containers, you’ve almost certainly heard of Docker. Docker is by far the most widely used container platform in industry and research. It’s easy to install, easy to build images with, and has a huge ecosystem. However, when it comes to HPC clusters, Docker is usually not the tool you can directly use. This is where Singularity becomes important. (Singularity is now often referred to as Apptainer, its successor. However, in this blog post I will continue to use the term Singularity, as this is still what my HPC system supports.)

Docker requires root-level privileges because it relies on the host kernel’s cgroups and namespaces to isolate processes. On a personal computer or lab workstation, this is perfectly fine. On a shared HPC cluster, giving users root privileges would be a security nightmare. For this reason, most HPC systems prohibit running Docker directly.

Therefore, the typical workflow, and the one we’ll use here, is to build a Docker image locally and then convert it into a Singularity image for use on the HPC.

## Making a docker image

First, install [Docker Desktop][docker] to your local machine.

A Dockerfile is a plaintext file that specifies the blueprint of your container, such as the base image, system packages, Python/Conda environments, and any other dependencies you require. You can write the Dockerfile yourself or ask ChatGPT to generate one based on a list of dependencies and requirements.

Once you have your Dockerfile, you can build a Docker image with:
`docker build -t image_name:tag_name -f /path/to/Dockerfile .`
If you open your Dockerfile in Visual Studio Code with the Docker extension installed, you can simply right-click the file and select “Build Image”, which runs the same command under the hood.

If the Dockerfile was generated entirely by ChatGPT (or written from scratch), the first build attempt may fail. In that case, you can paste the error message back into ChatGPT for suggestions, or fix the issue manually. After a few iterations, you should be able to build the image successfully.

## Test your image locally

Before converting the Docker image to a Singularity/Apptainer image, it’s worth testing the Docker image locally. This helps ensure that your environment contains all required packages and that your scripts run correctly. Because converting Docker images to Singularity images takes some time, it’s more efficient to catch mistakes at this stage.

To start a new container from an image, run:
`docker run -it --rm -it --gpus all -v C:\Users\Yuki\Documents\Projects\ProjectA:/proj_dir your_container_name bash`

* `-it` starts an interactive session (so you get a shell inside the container).
* `-rm` is to make sure the container will be desctroyed once you are finished.
* `--gpus all` gives the container access to GPU.
* `-v` maps a directory from your local machine into the container. This allows the container (a sandboxed environment) to read and write files in your local filesystem.

## Converting the docker image to Singularity one

There seems to exist a way to directly conver a docker image to a singularity image (especially with Apptainer??), but the way I learned is to first convert the docker image to a `.tar` file and then build a singularity image from the `.tar` file.
1. Export your Docker image as a `.tar` file
You can save a local Docker image into a portable archive with:
`docker save image_name:tag_name -o C:\User\Yuki\Downloads\image_name.tar`.
This .tar file contains the full image (layers, metadata, configuration) and can be transferred to the HPC cluster.

2. Upload the .tar file to the HPC
Use `scp`, `rsync`, or your institution’s file transfer system to upload the `.tar` file to the cluster.

3. Once the `.tar` file is on the cluster, create a Singularity `.sif` image from it:
   `singularity build /path/to/image_name.sif docker-archive:/path/to/image_name.tar`
This command unpacks the Docker archive, converts it into a squashfs filesystem, and packages it as a `.sif` file—the standard Singularity container format.

Now you have your custom Singularity image!

## Using Singularity image on HPC
Execute a Python script inside the container:

`singularity exec --nv --bind original_dir_path:/container --writable-tmpfs /path/to/your_singularity_image.sif python your_python_script.py`

Start an interactive shell inside the container:

`singularity shell --nv --bind original_dir_path:/container /path/to/your_singularity_image.sif`

Make sure to include `--nv` to enable GPU support and `--bind` to map directories from the host system into the container.
Also note that, when referencing files in your Python script, you must use the container-side paths (e.g., /container/your_data), since the script is executed inside the container rather than on the host filesystem.

Good luck!

[DeepLabCut]: https://deeplabcut.github.io/DeepLabCut/README.html
[SLEAP]: https://sleap.ai
[Kilosort]: https://github.com/MouseLand/Kilosort
[docker]: https://docs.docker.com/