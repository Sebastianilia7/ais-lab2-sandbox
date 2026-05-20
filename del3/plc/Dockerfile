FROM python:3.12-alpine
RUN pip install --no-cache-dir 'pymodbus[serial]==3.7.4'
COPY server.py /app/server.py
WORKDIR /app
CMD ["python", "server.py"]
