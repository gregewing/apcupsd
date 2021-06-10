This is a simple Ubuntu base with <code>apcupsd</code> installed. It manages and monitors a USB Connected UPS Device, and has the ability to gracefully shut down the host computer in the event of a prolonged power outage.  This is done with no customisation to the host whatsoever, there's no need for cron jobs on the host, or trigger files and scripts.  Everything is done within the container.

<b>Use Cases :</b><br>
Use this image if your UPS is connected to your docker host by USB Cable and you don't want to run <code>apcupsd</code> in the physical host OS.

Equally, this container can be run on any other host to monitor another instance of this container running on a host connected to the UPS for power status messages from the UPS, and take action to gracefully shut down the non-UPS connected host.

The purpose of this image is to containerise the APC UPS monitoring daemon so that it is separated from the OS, yet still has access to the UPS via USB Cable.  

It is not necessary to run this container in <code>privileged</code> mode.  Instead, we attach only the specific USB Device to the container using the <code>--device</code> directive in the <code>docker run</code> command.  However if you want the container to shut down the host when UPS battery power is critically low, then it is necessary to run the container in privileged mode and also expose the dbus socket responsible for triggering system shutdown, from the host to this container. See below in the Configuration section.

Other apcupsd images i've seen are for exporting monitoring data to grafana or prometheus, this image does not do that, though it does expose port 3551 to the network allowing for the apcupsd monitorig data to be captured using those other containers to handle flow of data into your preferred monitoring solution. Persoanlly, I use collectd to extract data from the apcupsd container, graphite capture the data and grafana to present pretty pictures.


<b>Configuration :</b>

Very little configuration is currently required for this image to work, though you may be required to tweak the USB device that is passed through to your container by docker.

<code>
docker run -it —privileged \<br>
  --name=apcupsd \<br>
  -e TZ=Europe/London \<br>
  --device=/dev/usb/<b>hiddev1</b> \<br>
  --restart unless-stopped \<br>
  -p=3551:3551 \<br>
  -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \<br>
  gregewing/apcupsd:latest
</code>
<br>

You will likely want to customise <code>/etc/apcupsd/apcupsd.conf</code> for each of the hosts that you run this container on, so it will need to be bind mounded for persistence purpoes.  I recommend setting the threshold for shutting down hosts not directly connected to the UPS a little higher than the host connected to the UPS, so that the remote hosts are able to shut down before the UPS Connected host is no longer available to provide signalling.

<b>Notes</b><br>
<ul type="disc">
<li>In case you're interested, I discovered that (at least my Smart UPS 3000) reports itself over USB as a <code>usbhid</code> device.  I discovered this by running <code>usb-devices</code> at the linux command line on the physical host that is connected to the UPS by USB, which told me the device type.  Looking in <code>/dev/usb/</code> I only had two to choose from, so I was able to hit on the correct one pretty quickly. This does not seem to change dunamically at boot, though I've not checked yet to see if it changes if I plug the USB Cable into a different port.</li>
<li>Testing was done by running the <code>apcaccess</code> on the physical host, and in the container, though you likely only need to run it in the container, after all, we don't want the APC UPS software installed in the host, that's the point of this image after all.  If the test is successful, then the output from <code>apcaccess</code> is quite a bit different compared with a fail scenario.  The difference should be self explanatory. This lets us know that the <code>apcupsd</code> daemon successfully connected to the UPS over the USB cable.  If all is well, port 3551 should also be exposed to the network allowing other systems to take a heartbeat signal from the UPS via this container.</li>
<li>You may wish to customise the <code>apcupsd.conf</code> file in <code>/etc/apcupsd/</code> but i'm pretty sure that the default settings are fine for most implementations.  The one exception may be the <code>UPSNAME</code> directive which you may wish to customise, but it doesnt appear to have a bearing on anything in my environment.</li>
<li>This container has the capability to gracefully shut down the physical host if there is a prolonged power failure. This is done using a DBus system call to the underlying host, though it’s necessary to run the container in privileged mode, and explicitly expose  /var/run/dbus/system_bus_socket  from the host into the guest. You can test this by running <code>/etc/apcupsd/apccontrol doshutdown</code> within this container, which should power off the host gracefully. This has been tested with the limited hosts I have in my lab environment and works successfully on Ubuntu 16.04 and 18.04 hosts.  Your mileage may vary.  If you run into difficulties, the action that triggers the host to shut down is in the <code>/etc/apcupsd/doshutdown</code> file inside the container.  This file contains commented out lines for restarting instead of shutting down, for use when testing.  it also has lines for managing Consolekit environments, which i'm lead to believe from my research behave differently in some way, but I've no way of testing this, so I just included them for completeness. For persistence, you may want to put this file on the host and bind mount it to the container as you've probably also already done with <code>/etc/apcupsd/apcupsd.conf</code>.</li>
<li>The apcupsd software operates a Network information Server model (NIS) for sharing information between hosts.  The remote hosts (those not directly connected to the UPS) poll the apcupsd instance that <u>is</u> directly connected to the UPS regular intervals.  All of this is customisable, for more information please see the apcupsd manual online here : <a href="http://www.apcupsd.org/manual/">APC UPS Daemon User Manual</a></li>
</ul>  
