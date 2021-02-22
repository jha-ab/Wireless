Step 1: Install bake
$ git clone https://gitlab.com/nsnam/bake

Step 2: Add bake to path in .bashrc file
$ export BAKE_HOME=`pwd`/bake 
$ export PATH=$PATH:$BAKE_HOME
$ export PYTHONPATH=$PYTHONPATH:$BAKE_HOME

Step 3: Create a contrib directory in the bake direcory and create a file sns3.xml there with the below xml.

<configuration>
  <modules>
    <module name="sns3-satellite" type="ns-contrib" min_version="ns-3.29">
      <source type="git">
        <attribute name="url" value="https://github.com/sns3/sns3-satellite.git"/>
        <attribute name="module_directory" value="satellite"/>
      </source>
      <build type="none">
      </build>
    </module>
    <module name="sns3-stats" type="ns-contrib" min_version="ns-3.29">
      <source type="git">
        <attribute name="url" value="https://github.com/sns3/stats.git"/>
        <attribute name="module_directory" value="magister-stats"/>
      </source>
      <build type="none">
      </build>
    </module>
    <module name="sns3-traffic" type="ns-contrib" min_version="ns-3.29">
      <source type="git">
        <attribute name="url" value="https://github.com/sns3/traffic.git" />
        <attribute name="module_directory" value="traffic"/>
      </source>
      <build type="none">
      </build>
    </module>
  </modules>
</configuration>

Step 4: Install sns3

./bake.py configure -e ns-3.29 -e sns3-satellite -e sns3-stats -e sns3-traffic
./bake.py deploy

Step 5: Recursive update the new sns3 files from git

cd source/ns-3.29/contrib/satellite
$ git submodule update --init --recursive

Step 6: Get the DVB-RCS2 data files from
https://forge.net4sat.org/sns3-data/sns-3-scenarios and paste to path.

Step 7: Paste the project.cc file in ~/bake/source/ns-3.29/scratch then navigate to ~/bake/source/ns-3.29

Step 8: Execute the command 
./waf --run project

Step 9: Enjoy! 

