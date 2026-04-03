#!/usr/bin/env python3
"""
LLaVA Species Identification API
Receives an image, sends to Ollama LLaVA for identification,
returns the identified species with confidence.

Run: uvicorn llava_api_server:app --host 0.0.0.0 --port 8089
"""

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import httpx
import base64
import json
import re

app = FastAPI(title="Galapagos Species ID API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

OLLAMA_URL = "http://localhost:11434/api/generate"

# Complete list of known Galapagos species (from Supabase DB)
KNOWN_SPECIES = [
    "Marine Iguana",
    "Galapagos Land Iguana",
    "Santa Cruz Giant Tortoise",
    "Galapagos Lava Lizard",
    "Blue-footed Booby",
    "Nazca Booby",
    "Magnificent Frigatebird",
    "Galapagos Penguin",
    "Waved Albatross",
    "Galapagos Hawk",
    "Medium Ground Finch",
    "Galapagos Sea Lion",
    "Galapagos Fur Seal",
    "Green Sea Turtle",
    "Galapagos Shark",
    "Scalloped Hammerhead Shark",
    "Galapagos Pink Land Iguana",
    "Eastern Galapagos Racer",
    "Hawksbill Sea Turtle",
    "Red-footed Booby",
    "American Flamingo",
    "Galapagos Flightless Cormorant",
    "Swallow-tailed Gull",
    "Galapagos Short-eared Owl",
    "Galapagos Dove",
    "Galapagos Yellow Warbler",
    "Galapagos Mockingbird",
    "Galapagos Brown Pelican",
    "Galapagos Great Blue Heron",
    "Lava Heron",
    "Great Frigatebird",
    "Galapagos Rice Rat",
    "Galapagos Red Bat",
    "Galapagos Hoary Bat",
    "Giant Oceanic Manta Ray",
    "Spotted Eagle Ray",
    "Whale Shark",
    "Pacific Seahorse",
    "Galapagos Reef Octopus",
    "White-tip Reef Shark",
    "Sally Lightfoot Crab",
    "Galapagos Painted Locust",
    "San Cristobal Giant Tortoise",
    "Espanola Giant Tortoise",
    "Alcedo Giant Tortoise",
    "Wolf Volcano Giant Tortoise",
    "Santiago Giant Tortoise",
    "Pinzon Giant Tortoise",
    "Sierra Negra Giant Tortoise",
    "Eastern Santa Cruz Giant Tortoise",
    "Fernandina Giant Tortoise",
    "Pinta Island Giant Tortoise (Lonesome George)",
    "Darwin Volcano Giant Tortoise",
    "Cerro Azul Giant Tortoise",
    "Santa Fe Land Iguana",
    "Central Galapagos Racer",
    "Western Galapagos Racer",
    "Espanola Racer",
    "Striped Galapagos Snake",
    "Yellow-bellied Sea Snake",
    "Loggerhead Sea Turtle",
    "Olive Ridley Sea Turtle",
    "Leatherback Sea Turtle",
    "Small Ground Finch",
    "Large Ground Finch",
    "Common Cactus Finch",
    "Large Cactus Finch",
    "Woodpecker Finch",
    "Small Tree Finch",
    "Vegetarian Finch",
    "Green Warbler Finch",
    "Mangrove Finch",
    "Galapagos Rail",
    "Lava Gull",
    "Espanola Mockingbird",
    "Floreana Mockingbird",
    "Galapagos Flycatcher",
    "Galapagos Vermilion Flycatcher",
    "Galapagos Petrel",
    "Galapagos Martin",
    "Bottlenose Dolphin",
    "Humpback Whale",
    "Orca (Killer Whale)",
    "Ocean Sunfish",
    "Porcupinefish",
    "Galapagos Spiny Lobster",
    "Black Sea Cucumber",
    "White Sea Urchin",
    "Floreana Giant Tortoise",
    "Santa Fe Giant Tortoise",
    "Sharp-beaked Ground Finch",
    "Vampire Ground Finch",
    "Genovesa Ground Finch",
    "Genovesa Cactus Finch",
    "Medium Tree Finch",
    "Large Tree Finch",
    "Grey Warbler Finch",
    "Cocos Finch",
    "San Cristobal Mockingbird",
    "Pinzon Island Racer",
    "Santiago Racer",
    "Sperm Whale",
    "Tortuga Island Racer",
    "Thomas Racer",
    "White-cheeked Pintail",
    "Yellow-crowned Night Heron",
    "Galapagos Oystercatcher",
    "Galapagos Shearwater",
    "Galapagos Barn Owl",
    "Wedge-rumped Storm Petrel",
    "Galapagos wolf spider",
    "Coastal wolf spider",
    "Dune wolf spider",
    "Dry zone wolf spider",
    "Transition zone wolf spider",
    "Espanola wolf spider",
    "Humid pampa wolf spider",
    "Silver garden spider",
    "Endemic orb-weaver",
    "Cone spider",
    "Galapagos black widow",
    "Huntsman spider",
    "Bellavista cave spider",
    "Isabela cave spider",
    "Blind cave spider",
    "Baert's Galapa spider",
    "Beautiful Galapa spider",
    "Floreana Galapa spider",
    "Short-finned Pilot Whale",
    "Common Dolphin",
    "Spinner Dolphin",
]

SPECIES_LIST_STR = ", ".join(KNOWN_SPECIES)

SPECIES_PROMPT = f"""You are a wildlife identification expert specialized in Galapagos Islands fauna.
Analyze the photo and identify the species. You MUST respond ONLY with valid JSON, no other text.

Known Galapagos species (respond with the exact name from this list):
{SPECIES_LIST_STR}

Respond with this JSON format:
{{"species": "exact species name from list above", "confidence": 0.0 to 1.0, "reasoning": "brief explanation"}}

If you cannot identify the species or it is not a Galapagos animal, respond:
{{"species": "unknown", "confidence": 0.0, "reasoning": "explanation"}}"""


@app.post("/identify")
async def identify_species(image: UploadFile = File(...)):
    """Identify a Galapagos species from an uploaded image."""
    image_bytes = await image.read()
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")

    payload = {
        "model": "llava:7b",
        "prompt": SPECIES_PROMPT,
        "images": [image_b64],
        "stream": False,
        "options": {
            "temperature": 0.1,
            "num_predict": 200,
        },
    }

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(OLLAMA_URL, json=payload)
        result = response.json()

    # Parse LLaVA response
    try:
        text = result.get("response", "")
        # Try to extract JSON from response
        json_match = re.search(r"\{.*\}", text, re.DOTALL)
        if json_match:
            data = json.loads(json_match.group())
            return {
                "species": data.get("species", "unknown"),
                "confidence": float(data.get("confidence", 0)),
                "reasoning": data.get("reasoning", ""),
                "source": "llava",
            }
    except Exception:
        pass

    return {
        "species": "unknown",
        "confidence": 0.0,
        "reasoning": "Could not parse identification result",
        "source": "llava",
    }


@app.get("/health")
async def health():
    """Check if the API and Ollama model are reachable."""
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get("http://localhost:11434/api/tags")
            models = resp.json().get("models", [])
            llava_loaded = any("llava" in m.get("name", "") for m in models)
        return {
            "status": "ok",
            "model": "llava:7b",
            "ollama_reachable": True,
            "llava_loaded": llava_loaded,
        }
    except Exception as e:
        return {
            "status": "degraded",
            "model": "llava:7b",
            "ollama_reachable": False,
            "error": str(e),
        }
