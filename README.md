
### INSTALL SCRIPT

<pre><code>sudo apt update</code></pre>
<h5>Install paket cek ssd dan hdd</h5>
<pre><code>sudo apt install smartmontools</code></pre>
<h5>Install paket cek nvme</h5>
<pre><code>sudo apt install nvme-cli
</code></pre>

<h5>download sc ini</h5>
<pre><code>wget https://github.com/gapesta/CEK-KESEHATAN-DISK/main/cek_disk.sh && chmod +x cek_disk.sh
</code></pre>
<h5>jalan sc ini sebagi root</h5>
<pre><code>sudo ./cek_disk.sh</code></pre>


### TEST

<h5>untuk cek nama ssd atau hdd gunaka perintah ini</h5>
<pre><code>lsblk</code></pre>
<h5>atau</h5>
<pre><code>lsblk -d -o name,rota,model</code></pre>


<h6>Kalau ROTA = 1 → HDD</h6>
<h6>Kalau ROTA = 0 → SSD</h6>
<h6>Lalu, disk-nya akan muncul sebagai /dev/sdX.</h6>