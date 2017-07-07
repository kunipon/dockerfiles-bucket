#!/bin/bash
set -e

case "$1" in
    rails|rake|passenger)
        if [ -e '/config/database.yml' ]; then
            if [ ! -f './config/database.yml' ]; then
                echo "use external database.uml file"
                ln -s /config/database.yml /usr/src/redmine/config/database.yml
            fi
        fi
        if [ -e '/config/configuration.yml' ]; then
            if [ ! -f './config/configuration.yml' ]; then
                echo "use external configuration.uml file"
                ln -s /config/configuration.yml /usr/src/redmine/config/configuration.yml
            fi
        fi
        if [ ! -f './config/database.yml' ]; then
            if [ "$REDMINE_DB_MYSQL" ]; then
                adapter='mysql2'
                host="${REDMINE_DB_MYSQL:-localhost}"
                port="${MYSQL_PORT_3306_TCP_PORT:-3306}"
                username="${MYSQL_ENV_MYSQL_USER:-root}"
                password="${MYSQL_ENV_MYSQL_PASSWORD:-$MYSQL_ENV_MYSQL_ROOT_PASSWORD}"
                database="${MYSQL_ENV_MYSQL_DATABASE:-${MYSQL_ENV_MYSQL_USER:-redmine}}"
                encoding=
            elif [ "$REDMINE_DB_POSTGRES" ]; then
                adapter='postgresql'
                host="${REDMINE_DB_POSTGRES:-localhost}"
                port="${POSTGRES_PORT_5432_TCP_PORT:-5432}"
                username="${POSTGRES_ENV_POSTGRES_USER:-postgres}"
                password="${POSTGRES_ENV_POSTGRES_PASSWORD}"
                database="${POSTGRES_ENV_POSTGRES_DB:-$username}"
                encoding=utf8
            else
                echo >&2 'warning: missing MYSQL_PORT_3306_TCP or POSTGRES_PORT_5432_TCP environment variables'
                echo >&2 '  Did you forget to --link some_mysql_container:mysql or some-postgres:postgres?'
                echo >&2
                echo >&2 '*** Using sqlite3 as fallback. ***'

                adapter='sqlite3'
                host='localhost'
                username='redmine'
                database='sqlite/redmine.db'
                encoding=utf8

                mkdir -p "$(dirname "$database")"
                chown -R redmine:redmine "$(dirname "$database")"
            fi

			cat > './config/database.yml' <<-YML
			$RAILS_ENV:
			  adapter: $adapter
			  database: $database
			  host: $host
			  username: $username
			  password: "$password"
			  encoding: $encoding
			  port: $port
			YML
        fi

        # ensure the right database adapter is active in the Gemfile.lock
        bundle install --without development test
        if [ ! -s config/secrets.yml ]; then
            if [ "$REDMINE_SECRET_KEY_BASE" ]; then
				cat > 'config/secrets.yml' <<-YML
				$RAILS_ENV:
				  secret_key_base: "$REDMINE_SECRET_KEY_BASE"
				YML
            elif [ ! -f /usr/src/redmine/config/initializers/secret_token.rb ]; then
                rake generate_secret_token
            fi
        fi
        if [ "$1" != 'rake' -a -z "$REDMINE_NO_DB_MIGRATE" ]; then
            gosu redmine rake db:migrate
        fi

        chown -R redmine:redmine files log public/plugin_assets

        if [ "$1" = 'passenger' ]; then
            # Don't fear the reaper.
            set -- tini -- "$@"
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_backlogs ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_backlogs /usr/src/redmine/plugins/
            bundle update nokogiri
            bundle install
            bundle exec rake db:migrate
            bundle exec rake tmp:cache:clear
            bundle exec rake tmp:sessions:clear
            set +e
            ./backlogs.exp
#            bundle exec rake redmine:backlogs:install RAILS_ENV="production"
            if [ $? -eq 0 ]; then
              echo "installed backlogs"
              touch /usr/src/redmine/plugins/redmine_backlogs/installed
            else
              echo "can't install backlogs"
            fi
            set -e
            touch /usr/src/redmine/plugins/redmine_backlogs/installed
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_local_avatars ]; then
          mv -f /usr/src/redmine/install_plugins/redmine_local_avatars /usr/src/redmine/plugins/
          bundle install --without development test
          bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_slack ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_slack /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_issue_templates ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_issue_templates /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_default_custom_query ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_default_custom_query /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_lightbox2 ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_lightbox2 /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_banner ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_banner /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_dmsf ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_dmsf /usr/src/redmine/plugins/
            bundle install --without development test xapian
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/redmine_omniauth_google ]; then
            mv -f /usr/src/redmine/install_plugins/redmine_omniauth_google /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        if [ -e /usr/src/redmine/install_plugins/view_customize ]; then
            mv -f /usr/src/redmine/install_plugins/view_customize /usr/src/redmine/plugins/
            bundle install --without development test
            bundle exec rake redmine:plugins:migrate RAILS_ENV=production
        fi
        set -- gosu redmine "$@"
                ;;
esac

exec "$@"
