String perfumeLabel(String? value) {
  if (value == null || value.trim().isEmpty) return '';
  const labels = {
    'women': 'Feminino',
    'men': 'Masculino',
    'unisex': 'Unissex',
    'low': 'Baixa',
    'moderate': 'Moderada',
    'high': 'Alta',
    'very high': 'Muito alta',
    'very low': 'Muito baixa',
    'honeysuckle': 'Madressilva',
    'vanilla': 'Baunilha',
    'caramel': 'Caramelo',
    'amber': 'Âmbar',
    'sandalwood': 'Sândalo',
    'mandarin orange': 'Tangerina',
    'white ginger lily': 'Lírio branco',
    'jasmine sambac': 'Jasmim sambac',
    'tonka bean': 'Fava tonka',
    'melon': 'Melão',
    'gardenia': 'Gardênia',
    'red currant': 'Groselha vermelha',
    'orange blossom': 'Flor de laranjeira',
    'wild berries': 'Frutas vermelhas',
    'rose': 'Rosa',
    'floral': 'Floral',
    'fresh': 'Fresco',
    'fruity': 'Frutado',
    'citrus': 'Cítrico',
    'aquatic': 'Aquático',
    'woody': 'Amadeirado',
    'sweet': 'Adocicado',
    'gourmand': 'Gourmand',
    'white floral': 'Floral branco',
  };
  final normalized = value.trim().toLowerCase();
  return labels[normalized] ?? value[0].toUpperCase() + value.substring(1);
}
