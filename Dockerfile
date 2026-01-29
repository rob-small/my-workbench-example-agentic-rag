FROM nvcr.io/nvidia/ai-workbench/python-basic:1.0.8

# Install system dependencies required for building packages
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Upgrade pip to resolve dependencies better
RUN pip install --upgrade pip setuptools wheel

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download NLTK data
RUN python3 -m nltk.downloader punkt averaged_perceptron_tagger

# Copy the entire project code
COPY code/ ./code/

# Copy the entire data directory
COPY data/ ./data/

# Copy environment variables file
COPY variables.env .

# Create project output directory
RUN mkdir -p /project/code

# Copy code to /project for application access
RUN cp -r /app/code /project/ 

# Create data mount point
RUN mkdir -p /project/data

# Expose the port the application runs on
EXPOSE 8080

# Set the working directory to the code folder
WORKDIR /app/code

# Load environment variables and run the chatui application
CMD ["python3", "-m", "chatui", "--host", "0.0.0.0", "--port", "8080"]
