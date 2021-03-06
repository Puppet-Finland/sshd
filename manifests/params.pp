#
# == Class: sshd::params
#
# Defines some variables based on the operating system
#
class sshd::params {

    include ::os::params

    case $::osfamily {
        'RedHat': {
            $package_name = 'openssh-server'
            $service_name = 'sshd'

            # In theory RedHat and Fedora versioning could collide here, but in 
            # practice that is highly unlikely.
            $host_keys = $::operatingsystemmajrelease ? {
                '7'     => ['rsa', 'ecdsa', 'ed25519' ],
                '6'     => ['dsa', 'rsa' ],
                default => ['rsa', 'ecdsa', 'ed25519' ],
            }
        }
        'Debian': {
            $package_name = 'openssh-server'
            $service_name = 'ssh'

            # Which SSH host keys get generated depends a lot on the 
            # distribution.
            $host_keys = $::lsbdistcodename ? {
                'focal'   => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'bionic'  => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'stretch' => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'xenial'  => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'jessie'  => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'trusty'  => ['rsa', 'dsa', 'ecdsa', 'ed25519' ],
                'precise' => ['rsa', 'dsa', 'ecdsa' ],
                'wheezy'  => ['rsa', 'dsa', 'ecdsa' ],
                default   => ['rsa', 'dsa', 'ecdsa', 'ed25519' ]
            }

        }
        'FreeBSD': {
            $service_name = 'sshd'

            $host_keys = $::operatingsystemmajrelease ? {
                '10'    => ['dsa', 'rsa', 'ecdsa', 'ed25519' ],
                default => ['dsa', 'rsa' ],
            }

        }
        default: {
            fail("Unsupported operatingsystem ${::operatingsystem}")
        }
    }

    if $::systemd {
        $service_start = "${::os::params::systemctl} start ${service_name}"
        $service_stop = "${::os::params::systemctl} stop ${service_name}"
    } else {
        $service_start = "${::os::params::service_cmd} ${service_name} start"
        $service_stop = "${::os::params::service_cmd} ${service_name} stop"
    }

    # This can be used to work around startup scripts that don't have a proper 
    # "status" target.
    $service_hasstatus = $::lsbdistcodename ? {
        default => true,
    }
}
