import ollama
import os

# 1. Load your Source of Truth
protocol_path = "malaria_protocol.md"
if not os.path.exists(protocol_path):
    # Create a dummy protocol if it doesn't exist for testing
    with open(protocol_path, "w", encoding="utf-8") as f:
        f.write("Artemether-Lumefantrine (AL) Dosage for Uncomplicated P. Falciparum:\n"
                "5-14kg: 1 tab BID for 3 days\n"
                "15-24kg: 2 tabs BID for 3 days\n"
                "25-34kg: 3 tabs BID for 3 days\n"
                "35kg+: 4 tabs BID for 3 days")

with open(protocol_path, "r", encoding="utf-8") as f:
    protocol_content = f.read()

def ask_malariaguard(user_input):
    # Ensure the system prompt is forceful and the content is clearly delimited
    response = ollama.chat(
        model="gemma4-hackathon",
        messages=[
            {
                "role": "system", 
                "content": (
                    "You are the MalariaGuard Clinical Decision Support Tool for Ethiopian Health Extension Workers. "
                    "You must answer using ONLY the protocol provided below. "
                    "If the protocol is present, do not ask the user for it; use it to answer.\n\n"
                    f"### ETHIOPIAN NATIONAL PROTOCOL DATA ###\n{protocol_content}\n"
                    "### END OF PROTOCOL DATA ###\n\n"
                    "INSTRUCTIONS:\n"
                    "1. Check for Danger Signs (Vomiting, inability to drink, convulsions, lethargy).\n"
                    "2. If no danger signs, output the exact number of tablets and frequency.\n"
                    "3. Be concise and technical."
                )
            },
            {"role": "user", "content": user_input}
        ]
    )
    return response["message"]["content"]

# 3. Test a Real Scenario
test_case = "I have a patient who weighs 22kg. RDT is positive for falciparum. No danger signs. What is the dose?"
print(f"User: {test_case}\n")
print(f"MalariaGuard: {ask_malariaguard(test_case)}")