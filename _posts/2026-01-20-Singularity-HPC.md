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

Many of us neuroscientists work with large datasets that benefit from GPU-based parallelization. For example, one might run machine-learning-based pose-tracking software such as [DeepLabCut] or [SLEAP] to extract animal positions from hours of video recordings. Or one might process extracellular recordings and extract spike times using spike-sorting software such as [Kilosort].

While these analyses can be run on a local machine, GPUs are expensive (often several hundred dollars, though I still think the ROI is great), and long analyses can easily exceed local memory limits (e.g., I’ve encountered memory issues running Kilosort4 on >5-hour recordings with 128-channel silicon probes as it accumulates detected spikes on the RAM). In such cases, running analyses on a high-performance computing cluster (HPC) becomes an attractive option, if you have access to one.

However, every institution configures its HPC differently. Some clusters allow you to freely create virtual environments (e.g., conda environments where you can install packages by yourself). Others—like the one I use daily—do not provide that flexibility. We were instructed to contact the HPC management team whenever we needed to install something or create a virtual environment, and responses were often slow (if they responded at all). As researchers, we can’t afford to wait around for someone else to press a button.


## What is a container

A powerful workaround is to use a container image. A container image is a self-contained, portable package that includes everything needed to run your workflow: code, libraries, dependencies, system tools, and even parts of the operating system. Once you have a container image (e.g., for spike sorting with Kilosort), you can run it (i.e., create a sandbox), perform your computations, and discard the sandbox when you’re done.

## Docker vs Singularity

If you’ve heard of containers, you’ve almost certainly heard of Docker. Docker is widely used in both industry and research. It’s easy to install, easy to build images with, and has a huge ecosystem. However, most HPC clusters do not allow Docker to run directly. This is where Singularity becomes important. (Singularity is now often referred to as Apptainer, its successor. For simplicity, I’ll use “Singularity,” since that’s what my HPC system supports.)

Docker requires root-level privileges because it relies on kernel features such as cgroups and namespaces to isolate processes. This is fine on a personal computer but unacceptable on a shared HPC cluster.

Therefore, the typical workflow, and the one we’ll use here, is:

1. Build a Docker image locally, and
2. Convert it into a Singularity image for use on the HPC.

## Making a docker image

First, install [Docker Desktop][docker] to your local machine.

A Dockerfile is a plaintext file that specifies the blueprint of your container, such as the base image, system packages, Python/Conda environments, and any other dependencies you require. You can write the Dockerfile yourself or ask ChatGPT to generate one based on a list of dependencies and requirements.

Once you have your Dockerfile, you can build a Docker image with:
`docker build -t image_name:tag_name -f /path/to/Dockerfile .`
If you open your Dockerfile in Visual Studio Code with the Docker extension installed, you can simply right-click the file and select “Build Image”, which runs the same command under the hood.

If the Dockerfile was generated entirely by ChatGPT (or written from scratch), the first build attempt may fail. In that case, you can paste the error message back into ChatGPT for suggestions, or fix the issue manually. After a few iterations, you should be able to build the image successfully.

## Test your image locally

Before converting your Docker image to a Singularity image, it’s worth testing it locally. This ensures that your environment includes all required packages and that your scripts run correctly. Since conversion to Singularity takes time, catching problems early is much more efficient.

To start a container from your image:

`docker run -it --rm -it --gpus all -v C:\Users\Yuki\Documents\Projects\ProjectA:/proj_dir your_container_name bash`

* `-it` starts an interactive session (so you get a shell inside the container).
* `-rm` removes the container automatically when you exit.
* `--gpus all` gives the container access to GPU.
* `-v` maps a directory from your local machine into the container. This allows the container (a sandboxed environment) to read and write files in your local filesystem.

## Converting the docker image to Singularity one

There seems to exist a way to directly conver a docker image to a singularity image (especially with Apptainer??), but the way I learned is to first convert the docker image to a `.tar` file and then build a singularity image from the `.tar` file.
1. Export your Docker image as a `.tar` file
You can save a local Docker image into a portable archive with:
`docker save image_name:tag_name -o C:\Users\Yuki\Downloads\image_name.tar`.
This .tar file contains the full image (layers, metadata, configuration) and can be transferred to the HPC cluster.

2. Upload the .tar file to the HPC
Use `scp`, `rsync`, or your institution’s file transfer system to upload the `.tar` file to the cluster.

3. Once the `.tar` file is on the cluster, create a Singularity `.sif` image from it:
   `singularity build /path/to/image_name.sif docker-archive:/path/to/image_name.tar`
This command unpacks the Docker archive, converts it into a squashfs filesystem, and packages it as a `.sif` file, the standard Singularity container format.

Now you have your custom Singularity image!

## Using a Singularity image on the HPC
Execute a Python script inside the container:

`singularity exec --nv --bind original_dir_path:/container --writable-tmpfs /path/to/your_singularity_image.sif python your_python_script.py`

Start an interactive shell inside the container:

`singularity shell --nv --bind original_dir_path:/container /path/to/your_singularity_image.sif`

Make sure to include `--nv` to enable GPU support and `--bind` to map directories from the host system into the container.
Also note that, when referencing files in your Python script, you must use the container-side paths (e.g., /container/your_data), because the script runs inside the container environment.

Good luck!

[DeepLabCut]: https://deeplabcut.github.io/DeepLabCut/README.html
[SLEAP]: https://sleap.ai
[Kilosort]: https://github.com/MouseLand/Kilosort
[docker]: https://docs.docker.com/