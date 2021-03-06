
@echo off
if exist tmp (
	REM Cleaning old sanbox
	@echo off
	cd tmp
	@echo off
	vagrant destroy -f
	@echo off
	cd ..
	@echo off
	rmdir /s /q tmp
)

REM Testing newly generated VM into a sandbox

vagrant box remove b2d-test
vagrant box add b2d-test boot2docker_virtualbox.box

REM Creating tmp VM
xcopy /S /Y /I tests tmp
cd tmp
vagrant init b2d-test

vagrant up
if %errorlevel% GEQ 1 (
	ECHO Could not vagrant up the basebox. See the log for details
)

REM testing basic vagrant SSH
@echo off
vagrant ssh -c 'whoami' -- -T -n
if %errorlevel% GEQ 1 (
	ECHO Could not vagrant ssh to the basebox. See the log for details
)

REM testing access to bats install script
@echo off
vagrant ssh -c "[ $(ls /vagrant | grep install_bats | wc -l) -eq 1 ] || exit 1" -- -T -n
if %errorlevel% GEQ 1 (
	ECHO Could not access install_bats on /vagrant into the basebox. See the log for details
)

REM launching Bats tests inside the VM
@echo off
vagrant ssh -c "/bin/bash /vagrant/install_bats.sh" -- -T -n
vagrant ssh -c "/vagrant/bats/bin/bats --tap /vagrant/*.bats" -- -T -n


vagrant destroy -f
cd ..
rmdir /s /q tmp
