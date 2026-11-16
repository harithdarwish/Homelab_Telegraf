# Homelab_Telegraf

Telegraf for prometheus to scrape host info.

Prerequisites:
- A fresh Linux environment (Debian 12 / Ubuntu recommended) 
- Root or sudo privileges to configure kernel parameters, install system packages, and run Docker.

---

## Steps

```bash 
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key && \
gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 | grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' && \
sudo mkdir -p /etc/apt/keyrings && \
cat influxdata-archive.key | gpg --dearmor | sudo tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null && \
echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list && \
sudo apt-get update && sudo apt-get install -y telegraf
------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------
sudo mkdir -p /opt/telegraf && cd /opt/telegraf/
---------------------------------------------------------------------
nano telegraf.conf
nano host_info.sh
---------------------------------------------------------------------
sudo chown -R telegraf:telegraf /opt/telegraf
usermod -aG docker telegraf 2>/dev/null
sudo nano /etc/systemd/system/telegraf.service.d/override.conf
sudo chmod 660 /var/run/docker.sock  && sudo chown root:docker /var/run/docker.sock
---------------------------------------------------------------------
sudo systemctl daemon-reload && sudo systemctl restart telegraf 
sudo systemctl status telegraf && ss -tulnp | grep 9273
curl -s http://127.0.0.1:9273/metrics | head -n 5
---------------------------------------------------------------------
sudo chmod +x /opt/telegraf/host_info.sh
sudo usermod -aG docker telegraf
sudo systemctl restart telegraf && sleep 30
curl -s http://localhost:9273/metrics | grep -E 'docker_image_info|lsblk_info' | cut -c1-200 | head -3
---------------------------------------------------------------------
nano prometheus.yml
docker volume ls
docker volume rm monitoring_prometheus-data
docker volume create monitoring_prometheus-data
docker volume create monitoring_grafana-data
docker compose up -d
docker compose down && docker compose up -d
---------------------------------------------------------------------
```
