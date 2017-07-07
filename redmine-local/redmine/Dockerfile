FROM redmine:3.3.3-passenger
MAINTAINER k_kawasaki@interspace.ne.jp

#必要コマンドのインストール
RUN apt-get update -y \
 && apt-get install -y curl unzip ruby ruby-dev cpp gcc libxml2 libxml2-dev \
  libxslt1-dev g++ git make xz-utils xapian-omega libxapian-dev xpdf \
  xpdf-utils antiword catdoc libwpd-tools libwps-tools gzip unrtf \
  catdvi djview djview3 uuid uuid-dev expect \
 && apt-get clean

#timezoneの変更（日本時間)
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
ENV RAILS_ENV production

#gitmakeテーマのインストール
RUN cd /usr/src/redmine/public/themes \
 && git clone https://github.com/makotokw/redmine-theme-gitmike.git gitmike \
 && chown -R redmine.redmine /usr/src/redmine/public/themes/gitmike

#redmine_github_hookのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/koppen/redmine_github_hook.git

#Redmine Information Pluginのインストール
RUN curl http://iij.dl.osdn.jp/rp-information/57155/rp-information-1.0.2.zip > /usr/src/redmine/plugins/rp-information-1.0.2.zip \
 && unzip /usr/src/redmine/plugins/rp-information-1.0.2.zip -d /usr/src/redmine/plugins/ \
 && rm -f /usr/src/redmine/plugins/rp-information-1.0.2.zip

#Redmine Good Job pluginのインストール
RUN curl -L https://bitbucket.org/changeworld/redmine_good_job/downloads/redmine_good_job-0.0.1.1.zip > /usr/src/redmine/plugins/redmine_good_job-0.0.1.1.zip \
 && unzip /usr/src/redmine/plugins/redmine_good_job-0.0.1.1.zip -d /usr/src/redmine/plugins/redmine_good_job \
 && rm -rf /usr/src/redmine/plugins/redmine_good_job-0.0.1.1.zip

#redmine_startpage pluginのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/txinto/redmine_startpage.git

#Redmine Lightbox Plugin 2 Pluginのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/peclik/clipboard_image_paste.git

#Google Analytics Pluginのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/paginagmbh/redmine-google-analytics-plugin.git google_analytics_plugin

#redmine_absolute_dates Pluginのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/suer/redmine_absolute_dates

#sidebar_hide Pluginのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/bdemirkir/sidebar_hide.git

#redmine_pivot_tableのインストール
RUN cd /usr/src/redmine/plugins \
 && git clone https://github.com/deecay/redmine_pivot_table.git

#backlogsのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN mkdir /usr/src/redmine/install_plugins \
 && cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/AlexDAlexeev/redmine_backlogs.git \
 && cd /usr/src/redmine/install_plugins/redmine_backlogs/ \
 && sed -i -e '11,17d' Gemfile

#redmine-slackのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/sciyoshi/redmine-slack.git redmine_slack

#Redmine Issue Templates Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/akiko-pusu/redmine_issue_templates.git redmine_issue_templates

#Redmine Default Custom Query Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/hidakatsuya/redmine_default_custom_query.git redmine_default_custom_query

#Redmine Lightbox Plugin 2 Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/paginagmbh/redmine_lightbox2.git redmine_lightbox2

#redmine_banner Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/akiko-pusu/redmine_banner.git redmine_banner

#redmine_dmsf Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/danmunn/redmine_dmsf.git redmine_dmsf

#redmine_omniauth_google Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/yamamanx/redmine_omniauth_google.git redmine_omniauth_google

#redmine_omniauth_google Pluginのインストール用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/onozaty/redmine-view-customize.git view_customize

#redmine_local_avatars用モジュールを用意(インストールはredmine起動時に実施)
RUN cd /usr/src/redmine/install_plugins \
 && git clone https://github.com/ncoders/redmine_local_avatars.git

#database.ymlファイルを置くフォルダを用意
#RUN mkdir /config
#COPY database.yml /config
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
COPY backlogs.exp /
RUN chmod +x /backlogs.exp

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000
CMD ["passenger", "start"]