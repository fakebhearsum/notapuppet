# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class beetmover_scriptworker {
    include beetmover_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include tweaks::scriptworkerlogrotate
    include tweaks::scriptworkerlogrotate

    $env_config = $beetmover_scriptworker::settings::env_config[$beetmoverworker_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python35'];
    }

    python35::virtualenv {
        $beetmover_scriptworker::settings::root:
            python3         => $packages::mozilla::python35::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python35'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => [
                'Jinja2==2.10.0',
                'MarkupSafe==1.0',
                'PyYAML==3.12',
                'aiohttp==2.3.1',
                'arrow==0.10.0',
                'async_timeout==1.4.0',
                'beetmoverscript==7.0.0',
                'boto3==1.5.19',
                'botocore==1.8.33',
                'certifi==2018.1.18',
                'chardet==3.0.4',
                'defusedxml==0.5.0',
                'dictdiffer==0.7.0',
                'docutils==0.14',
                'frozendict==1.2',
                'idna==2.6',
                'jmespath==0.9.3',
                'json-e==2.5.0',
                'jsonschema==2.6.0',
                'mohawk==0.3.4',
                'multidict==4.0.0',
                'pexpect==4.3.1',
                'ptyprocess==0.5.2',
                'python-dateutil==2.6.1',
                'python-gnupg==0.4.1',
                'redo==1.6',
                'requests==2.18.4',
                's3transfer==0.1.12',
                'scriptworker==10.2.0',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==2.1.3',
                'urllib3==1.22',
                'virtualenv==15.1.0',
                'yarl==1.0.0',
            ];
    }

    scriptworker::instance {
        $beetmover_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $beetmover_scriptworker::settings::root,

            task_script              => $beetmover_scriptworker::settings::task_script,
            task_script_config       => $beetmover_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $env_config["taskcluster_client_id"],
            taskcluster_access_token => $env_config["taskcluster_access_token"],
            worker_group             => $beetmover_scriptworker::settings::worker_group,
            worker_type              => $env_config["worker_type"],

            task_max_timeout         => $beetmover_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'beetmover',

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $beetmover_scriptworker::settings::verbose_logging,
    }

    file {
        "${beetmover_scriptworker::settings::root}/script_config.json":
            require   => Python35::Virtualenv[$beetmover_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template($env_config["config_template"]),
            show_diff => false;
    }
}
