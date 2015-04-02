## Vagrant intro

So you decided to give Vagrant a chance. Even if you won't like it, I think it's thing worth trying. Vagrant can improve your development workflow. Think about possible issues of not using VM:

**local environment painful setup:**

- new person in project
- laptop died

**OS dependency breaks production:**

- some dependencies in project needs compilation
- you don't want dual-boot on your Mac

**something else:**

- production contains several nodes - you don't want to flatten the design
- several projects on one machine lead to mess (different PSQL configs, for example)
- you just want to test your Salt config without fear

Actually, you can deal with it without virtualization. Hacking devel servers (if you have any)? Cool, but...

    Do you want risk leaving uncommited changes?
    Do you think commiting every possible test solution is worth your time?
    Do you collaborate or what?

Vagrant makes dumb easy creating development environment similar to devel/production.

    It's local, so you can hack it without conflicting with other devs in your project.
    It's clean, so moving and copying image is simple.
    It's isolated, so it won't affect your machine (not that true if you're evil genius).

So... Stay with me.

*In the following text "guest" means "local VM" and "host" - "bare metal OS".*

# Basic setup
Installing Vagrant is fairly simple.
Firstly, you need virtualization package (I use VirtualBox). I recommend installing the newest package.

    https://www.virtualbox.org/wiki/Downloads

Secondly, Vagrant. It's shipped with OS-suited packages:

    http://www.vagrantup.com/downloads.html

Check your installation with command:

    $ vagrant version

The response should be like this:

    Installed Version: 1.7.2
    Latest Version: 1.7.2

    You're running an up-to-date version of Vagrant!

To setup your VM you need at least basic image of the OS. We will call them "boxes". List your boxes:

    $ vagrant box list

Empty? No worries. Let's download one (you can find more [here](https://atlas.hashicorp.com/boxes/search?utm_source=vagrantcloud.com&vagrantcloud=1))

    $ vagrant box add ubuntu/trusty64

Now you're ready to clone the repo, if you haven't done that already, and build your first virtual environment.

    $ git clone https://github.com/Zhebr/vagrant_workshop.git

It has completed Vagrantfile, but if you really want completely new to Vagrant - please remove it.

    $ cd vagrant_workshop
    $ rm Vagrantfile

I will cover basic parts of Vagrant config step by step. After completing this tutorial, we'll have the Vagrantfile recreated.

*Note that every command beginning with "vagrant" will be run from host.*

# Up and down

Let's tell Vagrant, we want to create a VM:

    $ vagrant init

This command leaves Vagrantfile in current directory. Open the file and try to figure out what happens inside. Seems familiar? Yep - it's Ruby.

Now, insert name of your box in line 15:

    config.vm.box = "ubuntu/trusty64"

Then type in shell:

    $ vagrant up

and wait a while. It's coming up! Then check:

    $ vagrant status

If everything went fine - guest will be in "running" state.
I know it's quite short introduction, but if you feel tired or would love to take care of your onions - don't hesitate. But you probably want to know how to stop the guest.
There are three commands to do so:

    $ vagrant suspend  # dumps guest's RAM on host disk and shuts down VM
    $ vagrant halt     # shuts down VM
    $ vagrant destroy  # removes VM from disk

Are onions ok? Let's move on.
Just like in devel/production server you can ssh to guest:

    $ vagrant ssh

And... Welcome. You're inside.

Your user name is "vagrant". It has sudo (only in guest), so feel free to make some mess. Your changes mostly won't affect host machine. But before you do:

    $ sudo rm -rf /

Take a look:

    $ ls -la /vagrant

This is default shared directory between host and guest. It's synced folder. Changes made there are immediately visible on guest and host. So as long as you keep yourself away from synced folders - make your day.

# Vagrantfile

I'm used to keeping my projects in /home/<user> directory. To have "lameland" directory synced there, change line 40 in Vagrantfile:

    config.vm.synced_folder "lameland/", "/home/vagrant/lameland/"

To apply your changes made in Vagrantfile you need to reboot guest:

    $ vagrant reload

Works like charm.

# Building Rails app

Virtual machine is ready for setting up environment for your app. You can, of course, install whole stuff like you used to... However, I encourage you to dig into topic of automated environment setup (Puppet, Ansible etc.). For simplicity of this intro, there is a setup script in our working directory. We don't need this script to run on every boot. We only need it if we have bare machine or we changed something in the script. To achieve this, go to line 65 in Vagrantfile and type:

    config.vm.provision "shell", path: "setup.sh"

Now trigger reboot with provisioning:

    $ vagrant reload --provision

Boom!

Guest wakes up and after starting SSH server and mounting shared folders it runs our script.
But actually... What is happening in the script? Don't want to drown in details.
The script just updates packages, installs useful CLI tools and builds our app.

We can run the app with command (on guest):

    $ sudo docker-compose up

Boom! We have Rails server connected to PSQL, both running on guest machine! Can we see the app in web browser? Sadly - no. Keep in mind, Rails server opens guest's port 3000, but it doesn't affect host. What we need here is port forwarding. Assuming port 3000 is busy on host change line 25 in Vagrantfile.

    config.vm.network "forwarded_port", guest: 3000, host: 18080

Reboot guest without provisioning:

    $ vagrant reload

And type: http://localhost:18080/ in browser. You did it!

**What next?**

Now you can start developing your app. I recommend to dig deeper in Vagrant configuration (read about multi-machines and push), but also to try Docker and docker-compose. It's also good thing to change password to your database (I left this empty, hope you're wiser). **Happy hacking!**

# Hardware

You will probably want to customize amount of resources for guest. Just specify VM provider (in our case - VirtualBox) and set limits, like RAM available:

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
    end

# Collaboration

What if you want to show the feature you are working on to your team? Showing things on your screen is so "medieval", that's why Vagrant is shipped with interesting "share" functionality (you have to sign up [here](https://atlas.hashicorp.com/)).

    $ vagrant share        # generates URL for app running in your VM
    $ vagrant share --ssh  # allows your mates to ssh into your VM

Your mates don't need to have Vagrant installed. They just see link or another machine in network. It raises, of course, some security concerns, so read [this](http://docs.vagrantup.com/v2/share/security.html) before sharing your stuff with anyone.

# Re/sources:

0. [Vagrant](https://www.vagrantup.com/)
1. [Docker compose](https://docs.docker.com/compose/rails/)
