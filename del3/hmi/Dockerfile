FROM python:3.12-alpine
RUN pip install --no-cache-dir 'pymodbus[serial]==3.7.4'
COPY poller.py /app/poller.py
WORKDIR /app
CMD ["python", "-u", "poller.py"]
