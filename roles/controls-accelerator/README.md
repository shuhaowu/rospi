controls_accelerator
====================

This directory contains all the code and things needed so people who are not
familiar with Linux can relatively easily figure out what to do.

This contains several components:

- A generic help script where people can type `help` into command line and
  then.
- A simple HTTP interface to upload/download files..., along with the service
  file for systemd.
- Easy read/write of ROS topic:
  - A way to write the contents of a file into a ROS topic.
  - A way to read the contents of a ROS topic into a file while viewing it 
    at the same time.
  - These files can be uploaded/downloaded from the HTTP interface.
- A command to list what devices are attached to the Raspi (`lsgpio`?)

Some optional components so I can do technical support remotely (probably in a 
separate role):

- Static IP configuration?
- Newrelic?
- Tinc with remote SSH support?
