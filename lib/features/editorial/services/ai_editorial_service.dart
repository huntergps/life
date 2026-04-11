import 'package:galapagos_wildlife/features/ai_chat/services/ai_chat_service.dart';
import 'package:galapagos_wildlife/features/species/photo_id/services/gemma_species_service.dart';
import 'package:galapagos_wildlife/models/species.model.dart';

class AiEditorialService {
  static Future<String?> reviewSpeciesContent(Species species,
      {required bool isEs}) async {
    final status = await GemmaSpeciesService.checkStatus();
    if (status != GemmaModelStatus.ready) return null;

    final prompt = isEs
        ? 'Revisa esta ficha de especie y sugiere mejoras:\n'
            'Nombre: ${species.commonNameEs}\n'
            'Cientifico: ${species.scientificName}\n'
            'Descripcion: ${species.descriptionEs ?? "Sin descripcion"}\n'
            'Habitat: ${species.habitatEs ?? "Sin habitat"}\n\n'
            'Sugiere: 1) Datos faltantes 2) Errores potenciales 3) Informacion que agregaria valor. Maximo 5 puntos.'
        : 'Review this species card and suggest improvements:\n'
            'Name: ${species.commonNameEn}\n'
            'Scientific: ${species.scientificName}\n'
            'Description: ${species.descriptionEn ?? "No description"}\n'
            'Habitat: ${species.habitatEn ?? "No habitat"}\n\n'
            'Suggest: 1) Missing data 2) Potential errors 3) Information that would add value. Maximum 5 points.';

    try {
      return await AiChatService.sendMessage(prompt);
    } catch (_) {
      return null;
    }
  }
}
