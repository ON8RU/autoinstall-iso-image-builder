# ISO Image Builder for Autoinstall

Dependencies install:

```bash
chmod +x ./env.install.sh
chmod +x ./isobuilder.sh
./env.install.sh
```

Usage example:

```bash
./isobuilder.sh -iso cloud-ubuntu-22.04 -title "Ubuntu 22.04 LTS AUTO (EFIBIOS)" -source https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso -webserver "http://192.168.0.1:8181/"
./isobuilder.sh -iso cloud-ubuntu-24.10 -title "Ubuntu 24.10 LTS AUTO (EFIBIOS)" -source https://releases.ubuntu.com/24.10/ubuntu-24.10-live-server-amd64.iso -webserver "http://192.168.0.1:8181/"
```

After building iso image and MD5SUM has been placed into ./sources/[-iso]/dist directory

File structure for webserver:

- ROOT
  - meta-data
  - user-data
