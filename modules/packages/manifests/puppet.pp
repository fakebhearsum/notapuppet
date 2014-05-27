# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::puppet {
    anchor {
        'packages::puppet::begin': ;
        'packages::puppet::end': ;
    }

    $puppet_version = "3.4.2"
    $new_puppet_version = "3.6.1"
    $puppet_dmg_version = "${puppet_version}"
    $puppet_rpm_version = "${new_puppet_version}-1.el6"
    $puppet_deb_version = "${puppet_version}-1puppetlabs1"
    $facter_version = "1.7.5"
    $facter_dmg_version = "${facter_version}"
    $facter_rpm_version = "${facter_version}-1.el6"
    $facter_deb_version = "${facter_version}-1puppetlabs1"

    case $::operatingsystem {
        CentOS: {
            package {
                "puppet":
                    ensure => "$puppet_rpm_version";
                "facter":
                    ensure => "$facter_rpm_version";
            }
        }
        Ubuntu: {
            package {
                ["puppet", "puppet-common"]:
                    ensure => "$puppet_deb_version";
                ["facter"]:
                    ensure => "$facter_deb_version";
            }
        }
        Darwin: {
            # These DMGs come directly from http://downloads.puppetlabs.com/mac/
            Anchor['packages::puppet::begin'] ->
            packages::pkgdmg {
                puppet:
                    os_version_specific => false,
                    version => $puppet_dmg_version;
                facter:
                    os_version_specific => false,
                    version => $facter_dmg_version;
            } -> Anchor['packages::puppet::end']
        }
        Windows: {
            #Puppet installation is currently handled through GPO.
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
