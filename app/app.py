import os
import logging
from flask import Flask, jsonify

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

KEY_VAULT_URL = os.environ.get("KEY_VAULT_URL", "")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "dev")


def get_secret(secret_name: str) -> str:
    from azure.identity import ManagedIdentityCredential
    from azure.keyvault.secrets import SecretClient

    credential = ManagedIdentityCredential(
        client_id=os.environ.get("AZURE_CLIENT_ID")
    )
    client = SecretClient(
        vault_url=KEY_VAULT_URL,
        credential=credential
    )
    return client.get_secret(secret_name).value


@app.route("/")
def home():
    logger.info("Root endpoint called")
    return jsonify({
        "app": "azure-cicd-zerotrust-aks",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "status": "running"
    })


@app.route("/health")
def health():
    logger.info("Health check called")
    return jsonify({
        "status": "healthy"
    }), 200


@app.route("/secret")
def secret():
    logger.info("Secret endpoint called")

    if not KEY_VAULT_URL:
        logger.warning("KEY_VAULT_URL not configured")
        return jsonify({
            "error": "KEY_VAULT_URL not configured"
        }), 500

    try:
        secret_value = get_secret("app-secret")
        logger.info("Secret fetched successfully")
        return jsonify({
            "message": "Secret fetched via Managed Identity",
            "secret_exists": True,
            "secret_length": len(secret_value)
        })
    except Exception as e:
        logger.error(f"Failed to fetch secret: {str(e)}")
        return jsonify({
            "error": "Failed to fetch secret",
            "detail": str(e)
        }), 500


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False
    )