# FROM nginx:1.27.2
FROM registry.cn-qingdao.aliyuncs.com/xuxiaoweicomcn/nginx:1.27.2

LABEL maintainer="徐晓伟 <xuxiaowei@xuxiaowei.com.cn>"

ARG CI_PIPELINE_URL

ENV CI_PIPELINE_URL=${CI_PIPELINE_URL}

ADD .vitepress/dist /usr/share/nginx/html
ADD docker/nginx.conf /etc/nginx/conf.d/default.conf

RUN sed -i '/http {/a\    server_tokens off;' /etc/nginx/nginx.conf
