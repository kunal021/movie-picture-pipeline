FROM python:3.10-slim

ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_APP=__init__.py

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir flask flask-cors

EXPOSE 5000

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]
