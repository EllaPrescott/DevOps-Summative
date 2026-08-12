from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def dashboard():
    # Sample data for Version 1
    data = {
        "monthly_spend": 1250,
        "monthly_transactions": 42,
        "fraud_rate": "0.4%",
        "declines": 3
    }

    # Simple interactive element: user can add a transaction amount
    new_transaction = None
    if request.method == "POST":
        try:
            new_transaction = float(request.form.get("amount"))
            data["monthly_spend"] += new_transaction
            data["monthly_transactions"] += 1
        except:
            pass

    return render_template("index.html", data=data, new_transaction=new_transaction)

if __name__ == "__main__":
    app.run(debug=True)
