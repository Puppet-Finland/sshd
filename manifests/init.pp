#
# == Class: sshd
#
# Install and configure sshd
#
# == Parameters
#
# [*manage*]
#   Whether to manage sshd using Puppet or not. Valid values are true (default) 
#   and false.
# [*manage_config*]
#   Whether to manage sshd configuration using Puppet or not. Valid values are 
#   true (default) and false.
# [*manage_packetfilter*]
#   Manage packet filtering rules. Valid values are true (default) and false.
# [*manage_monit*]
#   Manage monit rules. Valid values are true (default) and false.
# [*listenaddress*]
#   Local IP-addresses sshd binds to. This can be an string containing one bind 
#   address or an array containing one or more. Defaults to "0.0.0.0" (all 
#   IPv4 interfaces).
# [*port*]
#   Port on which sshd listens on. Defaults to 22.
# [*allow_address_ipv4*]
#   Allow connections through the firewall from this IPv4 address/subnet only.
#   Passed to firewall resource's source parameter. For example '10.0.0.0/8'.
#   Defaults to allowing connections from any IPv4 address.
# [*allow_address_ipv6*]
#   Allow connections through the firewall from this IPv6 address/subnet only.
#   Passed to firewall resource's source parameter. Defaults to allowing
#   connections from any IPv6 address.
# [*limit*]
#   Rate limit for SSH connections. For example '3/min'. Only affects
#   iptables/ip6tables rules and is undef by default.
# [*permitrootlogin*]
#   Allow root logins (yes/no/without-password). Defaults to "yes".
# [*passwordauthentication*]
#   Allow logins using password (yes/no). Defaults to "yes".
# [*kerberosauthentication*]
#   Allow Kerberos authentication. This is required when using pam_winbind and 
#   logging in using credentials from Samba4 / Active Directory domain. Valid 
#   values are 'yes' and 'no' (default).
# [*gssapiauthentication*]
#   Allow GSSAPI authentication (e.g. for FreeIPA integration). Valid values are 
#   'yes' and 'no' (default).
# [*authorized_keys_from_sssd*]
#   Get authorized keys from SSSD. Valid values are true and false (default).
# [*monitor_email*]
#   Email address where local service monitoring software sends it's reports to.
#   Defaults to top scope variable $::servermonitor.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# Mikko Vilpponen <vilpponen@protecomp.fi>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class sshd
(
    Boolean $manage = true,
    Boolean $manage_config = true,
    Boolean $manage_packetfilter = true,
    Boolean $manage_monit = true,
            $listenaddress = '0.0.0.0',
            $port = 22,
            $allow_address_ipv4 = undef,
            $allow_address_ipv6 = undef,
            $limit = undef,
            $permitrootlogin = 'yes',
            $passwordauthentication = 'yes',
            $kerberosauthentication = 'no',
            $gssapiauthentication = 'no',
            $authorized_keys_from_sssd = false,
            $monitor_email = $::servermonitor
)
{

if $manage {

    $listenaddresses = any2array($listenaddress)

    include ::sshd::install

    if $manage_config {
        class { '::sshd::config':
            listenaddresses           => $listenaddresses,
            port                      => $port,
            permitrootlogin           => $permitrootlogin,
            passwordauthentication    => $passwordauthentication,
            kerberosauthentication    => $kerberosauthentication,
            gssapiauthentication      => $gssapiauthentication,
            authorized_keys_from_sssd => $authorized_keys_from_sssd,
        }
    }

    include ::sshd::service

    if $manage_packetfilter {
        class { '::sshd::packetfilter':
            port               => $port,
            allow_address_ipv4 => $allow_address_ipv4,
            allow_address_ipv6 => $allow_address_ipv6,
            limit              => $limit,
        }
    }

    if $manage_monit {
        class { '::sshd::monit':
            monitor_email => $monitor_email,
        }
    }
}
}
