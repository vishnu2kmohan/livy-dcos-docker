# Interactive Spark with JupyterLab and Apache Livy on Mesosphere DC/OS

## Prerequisites

Spin up a 9 private agent, 1 public agent DC/OS 1.10 Stable cluster

## Deploy Marathon-LB

```bash
dcos package install --yes marathon-lb
```

Note: If deploying Marathon-LB on Mesosphere DC/OS Enterprise, please use a service account and setup the appropriate ACLs as documented in [Provisoning Marathon-LB](https://docs.mesosphere.com/latest/networking/marathon-lb/mlb-auth)

Ref: [Deploy Marathon-LB on Mesosphere DC/OS Enterprise](https://github.com/vishnu2kmohan/dcos-toolbox/blob/master/marathon-lb/from-scratch-strict.sh)

## Deploy Apache Livy

```bash
dcos marathon app add https://github.com/vishnu2kmohan/livy-dcos-docker/raw/master/livy-marathon.json
```

Note: The default [livy.conf](https://s3.amazonaws.com/vishnu-mohan/livy/livy-mesos-client.conf) may be modified and rehosted on a webserver to suit your specific needs. Modify the [uri](https://github.com/vishnu2kmohan/livy-dcos-docker/blob/master/livy-marathon.json#L21) to point to its location your webserver.

## Deploy JupyterLab

Note: This JupyterLab setup has [BeakerX](http://beakerx.com) and [sparkmagic](https://github.com/jupyter-incubator/sparkmagic) preinstalled.

```bash
curl -O https://raw.githubusercontent.com/vishnu2kmohan/beakerx-dcos-docker/master/beakerx-sparkmagic-marathon.json
```

Edit and set the value of the `HAPROXY_0_VHOST` label to the hostname (or ideally, a unique CNAME) of the loadbalancer fronting the public agent(s) where Marathon-LB is installed. 

```bash
dcos marathon app add beakerx-marathon.json
```

Note: The default sparkmagic [config.json](https://s3.amazonaws.com/vishnu-mohan/sparkmagic/sparkmagic-dcos-config.json) may be modified and rehosted on a webserver to suit your specific needs. Modify the [uri](https://github.com/vishnu2kmohan/beakerx-dcos-docker/blob/master/beakerx-sparkmagic-marathon.json#L16) to point to its location on your webserver.

## Connect to JupyterLab

Point your web browser to the `VHOST` that was specified.

The default password is set to `jupyter` if you deployed the app to `/beakerx` using the default Marathon app definition.

If you modified and deployed the app into a folder, e.g., `/foo/bar/beakerx` the auto-configured password will be `jupyter-foo-bar`

Ref: [Jupyter Notebook Password Provisioning](https://github.com/vishnu2kmohan/beakerx-dcos-docker/blob/master/jupyter_notebook_config.py#L23-L27)

## Start a `PySpark3` notebook from the JupyterLab launched and paste the following code into a cell

### SparkPi

```python3
from random import random 
from operator import add

partitions = 10
n = 100000 * partitions

def f(_):
    x = random() * 2 - 1
    y = random() * 2 - 1
    return 1 if x ** 2 + y ** 2 <= 1 else 0

n = 100000 * 50
count = sc.parallelize(range(1, n + 1), partitions).map(f).reduce(add)
print("Pi is roughly %f" % (4.0 * count / n))
```

`Ctrl-Enter` to execute the code in the cell, which will trigger [sparkmagic](https://s3.amazonaws.com/vishnu-mohan/sparkmagic/sparkmagic-dcos-config.json) to [communicate](https://github.com/vishnu2kmohan/beakerx-dcos-docker/blob/master/sparkmagic-dcos-config.json) with Apache Livy where its [livy.conf]() has been [configured](https://github.com/vishnu2kmohan/livy-dcos-docker/blob/master/livy-mesos-client.conf#L35) to spawn Spark Executors on your Mesosphere DC/OS cluster.

## References

- [Apache Livy](https://livy.incubator.apache.org)
- [Apache Livy for Mesosphere DC/OS GitHub Repo](https://github.com/vishnu2kmohan/livy-dcos-docker)
- [Apache Livy for Mesosphere DC/OS Docker Image](https://hub.docker.com/r/vishnumohan/livy-dcos)
- [BeakerX](http://beakerx.com)
- [BeakerX for Mesosphere DC/OS GitHub Repo](https://github.com/vishnu2kmohan/beakerx-dcos-docker)
- [BeakerX for Mesosphere DC/OS Docker Image](https://hub.docker.com/r/vishnumohan/beakerx-sparkmagic-dcos)
- [Mesosphere DC/OS](https://dcos.io)
- [Mesosphere DC/OS Enterprise](https://mesosphere.com/product)
- [Anaconda](https://www.anaconda.com)
- [Conda](https://conda.io)
- [Miniconda3 Docker GitHub Repo](https://github.com/vishnu2kmohan/miniconda3-docker)
- [Miniconda3 Docker Image](https://hub.docker.com/r/vishnumohan/miniconda3)
- [Debian](https://www.debian.org
- [debian:jessie Docker Image](https://hub.docker.com/r/library/debian)
