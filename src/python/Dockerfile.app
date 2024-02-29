FROM python:3.10-slim

EXPOSE 8080

WORKDIR /app
COPY ./requirements.txt ./app.py .
RUN pip3 install -r ./requirements.txt

CMD ["python", "app.py"]