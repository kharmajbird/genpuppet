#
# fun with genpuppet :)
#
class common::cold {
    include nasty_bacteria::bootstrap

    file { 'fluids':
        ensure => 'tasty',
        mode => 'hot',
        owner => 'jlewis',
    }
    file { 'blanket':
        ensure => 'exists',
        mode => 'flannel',
        owner => 'jlewis',
        require => [
            File['couch'],
        ],
    }
    file { 'couch':
        ensure => 'vacant',
        mode => 'comfortable',
        owner => 'jlewis',
        before => [
            Exec['cough'],
            Exec['sneeze'],
            Exec['blow-nose'],
        ],
        require => [
            File['fluids'],
            File['care-package'],
            Service['netflix'],
        ],
    }
    file { 'space-heater':
        ensure => 'two-feet-away',
        mode => 'cranked',
        owner => 'jlewis',
        require => [
            File['blanket'],
        ],
    }
    file { 'care-package':
        ensure => 'on-coffee-table',
        mode => 'within-reach',
        content => [ 'soup', 'kleenex', 'vitaminC' ],
        owner => 'jlewis',
        require => [
            Service['significant-other'],
        ],
    }
    service { 'remote-control':
        ensure => 'exists',
        require => [
            Service['significant-other'],
        ],
    }
    service { 'significant-other':
        ensure => 'exists',
        restart => 'honey-do',
    }
    service { 'netflix':
        ensure => 'exists',
        require => [
            Service['remote-control'],
            File['care-package'],
            File['couch'],
        ],
    }
    exec { 'blow-nose':
        command => '/bin/honk',
        logoutput => '/var/log/kleenex',
        before => [
            Exec['cough'],
        ],
        require => [
            Exec['sneeze'],
        ],
    }
    exec { 'cough':
        command => '/usr/bin/hack-up-lung.pl',
        creates => '/tmp/phlem',
        logoutput => '/var/log/kleenex',
    }
    exec { 'sneeze':
        command => '/usr/local/bin/ah-choo.sh',
        onlyif => 'test -f /tmp/nasty-bacteria'
    }
    host { 'my_body':
        ensure => 'feverish',
        ip => [
            10.8.24.71,
        ],
    }
    user { 'jlewis':
        ensure => 'annoyed',
        comment => 'Host infected',
        groups => 'sickfolks',
        home => '/home/ill',
        name => 'James Lewis',
        shell => '/bin/honk',
    }


}
