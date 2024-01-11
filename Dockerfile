FROM python:3.9

# Create a non-root user
RUN useradd -m -U -u 1000 flaskuser

# Set the working directory to /app
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY app.py .

COPY templates /app/templates

# Change ownership of the application files to the created user
RUN chown -R flaskuser:flaskuser /app

# Switch to the created user
USER flaskuser

# Expose port 5000 to the world
EXPOSE 5000

# CMD specifies the command to run on container start
CMD ["python", "app.py"]
