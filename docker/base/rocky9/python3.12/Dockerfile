FROM harbor.zetyun.cn/dingofs/dingo-eureka:rocky9-test

RUN python3.12 -m venv /opt/venv && source /opt/venv/bin/activate && pip install --upgrade pip

ENV PATH="/opt/venv/bin:$PATH"
