# Emergent Behaviour Simulation

This project is a **Godot-based simulation** developed for an **Extended Project Qualification (EPQ)**, which achieved an **A*** grade with a score of **47/50**.  
It explores **emergent behaviour** in artificial life by simulating interactions between autonomous agents with simple rules, leading to complex and sometimes unexpected group dynamics.

---

## Project Overview

The simulation consists of two main agent types:

- **Food Gatherers** – Red - seek out and collect resources.
- **Fighters** – Green - prioritise defence and combat threats.
- **Predators** – Yellow - hunt and attack other agents.

Agents operate without central control, following simple rule sets. Through repeated interactions, **emergent behaviours** appear that were not explicitly programmed.

---

## Key Emergent Behaviours

### 1. Escort Dynamics (Primary Discovery)

One of the most compelling outcomes of the simulation was the spontaneous emergence of **escort dynamics** — a form of cooperative behaviour that was *never explicitly programmed*.

In multiple runs, **Fighters** began positioning themselves along the travel paths of **Food Gatherers**, effectively acting as defensive escorts. This pattern arose from the agents’ independent decision-making rules and environmental pressures, not from any centralised control.

**Key observations:**
- **Self-Organised Convoy Structure** – Fighters naturally stationed themselves along forager trails, creating a moving “safe corridor” through contested areas.
- **Passive Protection Mechanism** – While Fighters pursued their own objectives, their presence reduced risk to nearby foragers.
- **Increased Resource Security** – Escort behaviour correlated with higher food return rates and reduced forager losses.

![Escort Dynamics](https://i.imgur.com/XySlyjQ.png)

This emergent cooperation mirrors behaviours observed in **biological systems** (e.g., soldier ants protecting worker ants) and demonstrates the potential for **complex group strategies** to arise from simple local rules.

### 2. Optimal Path Formation (Secondary Behaviour)

Food Gatherers refine their travel routes over time, converging on **increasingly efficient**, straighter paths to access resources. Earlier wide, curved green pheromone trails gradually straighten, showing the emergent optimisation of movement through repeated agent interactions.

![Optimal Path Formation](https://i.imgur.com/wfW8CIm.png)

---
## Running the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/ayan-droid/Emergent-Behaviour-Simulation-.git
2. Open the project in Godot 4.x.
3. Run the main scene to start the simulation.

---
## Project Context

This simulation was originally developed as part of my Extended Project Qualification (EPQ) titled:

> *"Create a Computer Simulation in order to show how Emergent Behaviour can appear from Artificial Life"*

The final outcome successfully met the objectives set out in the project specification, demonstrating that simple, decentralised rules can lead to complex and unexpected emergent behaviours in artificial life.

---
## Contact
For questions, feedback, or collaboration requests, please contact:  
📧 your.email@example.com

---
If you found this project interesting or useful, consider giving it a ⭐ on GitHub!
