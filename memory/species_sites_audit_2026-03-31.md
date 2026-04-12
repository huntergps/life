# Species-Site Associations Audit (2026-03-31)

## Scope: Species IDs 31-131

## CRITICAL ERRORS FOUND

### 1. Floreana Mockingbird (id=76) - WRONG ISLAND
- **Current**: LUZ DEL DIA (Floreana main island), species_sites.id=2504
- **Correct**: ONLY on Champion and Gardner-by-Floreana islets (extinct on Floreana since 1880s)
- **Action**: DELETE from LUZ DEL DIA, INSERT for ISLOTE CHAMPION (vs.id=730) and ISLOTE GARDNER (vs.id=315)
- **Source**: Wikipedia, Darwin Foundation, PMC studies

### 2. Sharp-beaked Ground Finch (id=92) - WRONG ISLANDS
- **Current**: Fernandina, Floreana, Isabela, Santa Cruz, Santiago (23 sites)
- **Correct**: ONLY Santiago, Fernandina, Pinta (highland forests)
- **Action**: DELETE all sites on Floreana (5), Isabela (7), Santa Cruz (8). Keep Fernandina (1) and Santiago (2).
- **Wrong site IDs**: 2631, 2647, 2645, 2640, 2638 (Floreana), 2628, 2630, 2633, 2634, 2639, 2643, 2646 (Isabela), 2635, 2627, 2642, 2644, 2626, 2637, 2625, 2636 (Santa Cruz)
- **Source**: Birds of the World, Darwin Foundation dataZone

### 3. Large Ground Finch (id=65) - WRONG ISLANDS
- **Current**: Floreana, Genovesa, Isabela, San Cristobal, Santa Cruz, Santiago
- **Correct**: ABSENT from Floreana, San Cristobal, Espanola, Santa Fe. Present on Fernandina (missing)
- **Action**: DELETE all sites on Floreana and San Cristobal. Should ADD Fernandina.
- **Source**: Wikipedia, Darwin Foundation dataZone, Birds of the World

### 4. Tortuga Island Racer (id=109) - WRONG ISLAND
- **Current**: Isabela + MOSQUERA (species_sites.id=869)
- **Correct**: Isabela, Fernandina, Tortuga islet only. NOT on Mosquera.
- **Action**: DELETE Mosquera site (id=869)
- **Source**: Reptiles of Ecuador, Wikipedia

### 5. Galapagos Rail (id=73) - MANY WRONG SITES (coastal instead of highland)
- **Current**: 22 sites across Isabela, San Cristobal, Santa Cruz (mostly coastal)
- **Correct**: ONLY highland humid zones. The rail does NOT live on beaches or coastal areas.
- **Wrong coastal sites to DELETE**: CALERA, CALETA TAGUS, CARTAGO CHICO, CENTRO DE CRIANZA ARNALDO TUPIZA, LOBERIA GRANDE, LOS TUNELES (Isabela coastal); BAHIA ROSA BLANCA, BAHIA SARDINA, CENTRO DE CRIANZA DAVID RODRIGUEZ, JARDIN DE LAS OPUNTIAS, LA TORTUGA, PLAYA BONITA, PUNTA CAROLA (San Cristobal coastal); BAHIA BALLENA, BAHIA BORRERO, CERRO DRAGON, LAGUNA DE LAS NINFAS, PLAYA ESCONDIDA, TORTUGA BAY (Santa Cruz coastal)
- **Keep**: RESERVA EL CHATO, LOS GEMELOS, MIRADOR DE LOS TUNELES (Santa Cruz highlands)
- **Missing**: Santiago, Fernandina, Floreana highland sites
- **Source**: Birds of the World, Cambridge University study, Conservation Evidence

### 6. Galapagos Petrel (id=79) - MISSING 4 ISLANDS
- **Current**: Only Santa Cruz (9 sites)
- **Correct**: Nests in highlands of Santa Cruz, Floreana, Santiago, San Cristobal, Isabela
- **Action**: ADD highland sites on Floreana, Santiago, San Cristobal, Isabela
- **Source**: Wikipedia, BirdLife, Birds of the World

### 7. Western Galapagos Racer (id=57) - MISSING Fernandina
- **Current**: Only Isabela (8 sites)
- **Correct**: Isabela AND Fernandina
- **Action**: ADD Punta Espinoza (Fernandina, vs.id=735)
- **Source**: Reptiles of Ecuador, Wikipedia

### 8. Sperm Whale (id=108) - TOO RESTRICTED
- **Current**: Only Darwin (2 marine sites)
- **Correct**: Deep waters around entire archipelago, especially Fernandina/Isabela channel, Wolf, Darwin
- **Action**: ADD Wolf and Fernandina marine sites
- **Source**: NOAA, research papers, whale watching guides

### 9. Vermilion Flycatcher (id=78) - MISSING Fernandina, Santiago
- **Current**: Only Isabela, San Cristobal, Santa Cruz
- **Correct**: Also on Fernandina, Santiago, Pinzon, Pinta, Marchena (stable populations)
- **Action**: ADD Fernandina (Punta Espinoza) and Santiago sites at minimum
- **Source**: Galapagos Conservancy, Birds of the World

### 10. Wedge-rumped Storm Petrel (id=116) - MISSING breeding colonies
- **Current**: Only Genovesa (2 sites)
- **Correct**: Also breeds on Punta Pitt (San Cristobal) and Roca Redonda (off Isabela)
- **Action**: ADD Punta Pitt (vs.id=847) and Roca Redonda (vs.id=715)
- **Source**: Birds of the World, Wikipedia

### 11. Barn Owl (id=115) - MISSING Fernandina, Santiago, Espanola
- **Current**: Floreana, Isabela, San Cristobal, Santa Cruz
- **Correct**: Also on Fernandina, Santiago, Espanola
- **Action**: ADD sites on missing islands
- **Source**: birdfinding.info, Galapagos Conservation Trust, PMC studies

### 12. Galapagos Martin (id=80) - MISSING many islands
- **Current**: Floreana, Isabela, San Cristobal, Santa Cruz
- **Correct**: Also on Fernandina, Santiago, Pinzon, Daphne, Baltra, Seymour, Santa Fe, Espanola
- **Source**: Birds of the World, Wikipedia, Cambridge University study

## SPECIES WITH ACCEPTABLE DATA (verified correct)

- **Great Frigatebird (31)**: Widespread, 98 sites across many islands - OK
- **Galapagos Red Bat (33)**: Sites are reasonable (forests/caves, not open beaches) - OK
- **Galapagos Hoary Bat (34)**: Sites reasonable - OK
- **Giant Oceanic Manta Ray (35)**: Marine sites, correct islands - OK
- **Spotted Eagle Ray (36)**: Marine sites widespread - OK
- **Whale Shark (37)**: Only Darwin/Wolf - CORRECT
- **Pacific Seahorse (38)**: Marine sites reasonable - OK
- **Galapagos Reef Octopus (39)**: Marine sites widespread - OK
- **White-tip Reef Shark (40)**: Marine sites widespread - OK
- **Sally Lightfoot Crab (41)**: Ubiquitous, 158 sites - OK
- **Galapagos Painted Locust (42)**: Widespread - OK
- **Giant Tortoises (43-54)**: Each on correct island - OK
- **Santa Fe Land Iguana (55)**: Only Santa Fe - CORRECT
- **Central Galapagos Racer (56)**: Santa Cruz + Seymour Norte - OK (missing Baltra/Santa Fe but acceptable for tourist sites)
- **Espanola Racer (58)**: Only Espanola - CORRECT
- **Striped Galapagos Snake (59)**: Multi-island - OK
- **Yellow-bellied Sea Snake (60)**: Pelagic, marine sites - OK
- **Sea turtles (61-63)**: Marine sites - OK
- **Darwin's finches (64, 66-70)**: Distributions reasonable - OK
- **Large Cactus Finch (67)**: Only Espanola + Genovesa - CORRECT
- **Mangrove Finch (72)**: Only Isabela (2 sites) - CORRECT
- **Vampire Ground Finch (93)**: Only Darwin + Wolf - CORRECT
- **Genovesa Ground Finch (94)**: Only Genovesa - CORRECT
- **Genovesa Cactus Finch (95)**: Only Genovesa - CORRECT
- **Medium Tree Finch (96)**: Only Floreana - CORRECT
- **Espanola Mockingbird (75)**: Only Espanola - CORRECT
- **San Cristobal Mockingbird (104)**: Only San Cristobal - CORRECT
- **Pinzon Racer (106)**: Only Pinzon - CORRECT
- **Santiago Racer (107)**: Only Santiago - CORRECT
- **Thomas Racer (110)**: Only Santiago - CORRECT
- **Bottlenose Dolphin (81)**: Marine sites widespread - OK
- **Humpback Whale (82)**: Isabela + Wolf - OK (could add Fernandina)
- **Orca (83)**: Fernandina + Isabela - CORRECT
- **Ocean Sunfish (84)**: Marine sites reasonable - OK
- **Lava Gull (74)**: Isabela, San Cristobal, Santa Cruz - OK (widespread species)
- **Spiders (117-131)**: Sites match species_islands table - OK
- **Cocos Finch (99)**: Zero sites - CORRECT (not found in Galapagos)
