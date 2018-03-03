# Travlendar+

This is a prototype for the Travlendar+ project, described more in details in the [master](https://github.com/TommasoBianchi/BettiBianchi_SWENG2/tree/master) branch of this repository.
It can be either cloned and run locally or tried online at http://travlendar.it.

## How to install

### Install Ruby

You can find full installation instruction for the Ruby language [here](https://www.ruby-lang.org/en/documentation/installation/). Below there is a short summary for the most used operating systems.

* Linux rvm (tested and suggested)}

RVM (Ruby Version Manager) is a command-line tool which allows you to easily install, manage, and work with multiple ruby environments from interpreters to sets of gems. To install it open a terminal and copy-paste the following code:

```
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev curl
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable 
source ~/.rvm/scripts/rvm
rvm install 2.5.0
rvm use 2.5.0 --default
gem install bundler
```

* Linux (Debian or Ubuntu)

Open a console and type in ```sudo apt-get install ruby-full```

* Windows

Download the installer from [here](http://railsinstaller.org/en), then run it.

* MacOSX (Using Homebrew)

Open a console and type ```brew install ruby```

* MacOSX (Installer)

Download the installer from [here](http://railsinstaller.org/en), then run it.

### Install Rails

If you have installed Ruby through the installer you should already have also Rails, otherwise just open a console and type 
```gem install rails```
(NOTE: this may require to manually solve some dependencies if you havent't used rvm).

It is also required to have nodejs in the environment for the Rails Assets Pipeline, and you can install it typing the following in a console (linux):

```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Install PostgreSQL

Download the installer for you operating system from [here](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads#linux), selecting the 9.6.6 version.

After the installation is complete, open the postgreSQL console by typing in a console ```sudo -u postgres psql``` on Linux/MacOSX (if command psql is not found navigate to the installation folder of postgreSQL and you can find it under the bin/ folder) or ```c:\textbackslash~path\textbackslash~to\textbackslash~psql.exe -U postgres;``` on Windows; then create a user typing ```create user travlendar with createdb password '0000';```

### Setup and Run

Clone the source code from [here](https://github.com/TommasoBianchi/BettiBianchi_SWENG2) if you haven't already, then navigate to the Travlendar folder.

Open a console and type ```bundle install``` to download all the dependencies, then ```rake db:setup``` to build the database and finally ```rails server``` to run the rails server on localhost.

In case you have problems installing the pg gem, try running ```bundle config build.pg --with-pg-config=[path_to_postgres_installation]/bin/pg_config;```

You should now be able to access the application on http://localhost:3000/.
