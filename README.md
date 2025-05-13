
### INSTALL SCRIPT

<pre><code>sudo apt update</code></pre>
<h1>Install paket cek ssd dan hdd</h1>
<pre><code>sudo apt install smartmontools</code></pre>
<h1>Install paket cek nvme</h1>
<pre><code>sudo apt install nvme-cli
</code></pre>

<h1>download sc ini</h1>
<pre><code>wget https://github.com/gapesta/CEK-KESEHATAN-DISK/main/cek_disk.sh && chmod +x cek_disk.sh
</code></pre>



### TEST

<h1>untuk cek nama ssd atau hdd gunaka perintah ini</h1>
<pre><code>lsblk</code></pre>
<h1>atau</h1>
<pre><code>lsblk -d -o name,rota,model</code></pre>


<h2>Kalau ROTA = 1 → HDD</h2>
<h2>Kalau ROTA = 0 → SSD</h2>
<h2>Lalu, disk-nya akan muncul sebagai /dev/sdX.</h2>