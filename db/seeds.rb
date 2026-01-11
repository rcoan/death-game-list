# Only clear data in development
if Rails.env.development?
  PlayerList.destroy_all
  Celebrity.destroy_all
  User.destroy_all
  GameYear.destroy_all
end

# Helper to generate username from name
def generate_username(name)
  name.downcase
     .gsub(/[^a-z0-9]/, '_')
     .gsub(/_+/, '_')
     .gsub(/^_|_$/, '')
end

# Função genérica para popular um ano
def seed_year(year, game_year_config, all_deaths, players_data)
  # Verificar se o ano já foi populado (em produção)
  if Rails.env.production? && PlayerList.where(year: year).exists?
    puts "Year #{year} already has data in production. Skipping."
    return
  end

  puts "\n" + "="*80
  puts "Seeding year #{year}"
  puts "="*80

  # Criar/atualizar GameYear
  game_year = GameYear.find_or_create_by(year: year) do |gy|
    gy.is_active = game_year_config[:is_active] || false
    gy.start_date = game_year_config[:start_date] || Date.new(year, 1, 15)
    gy.locked = game_year_config[:locked] || false
  end
  
  # Atualizar se já existir
  game_year.update!(
    is_active: game_year_config[:is_active] || false,
    start_date: game_year_config[:start_date] || Date.new(year, 1, 15),
    locked: game_year_config[:locked] || false
  )

  # Criar todas as celebridades mortas primeiro
  all_deaths.each do |name, death_info|
    celebrity = Celebrity.where('LOWER(name) = ?', name.downcase).first
    if celebrity
      celebrity.update!(
        is_deceased: true,
        age_at_death: death_info[:age],
        death_date: death_info[:date],
        points: death_info[:points]
      )
    else
      Celebrity.create!(
        name: name,
        is_deceased: true,
        age_at_death: death_info[:age],
        death_date: death_info[:date],
        points: death_info[:points]
      )
    end
  end

  # Criar usuários e suas listas
  players_data.each do |name, data|
    username = data[:username] || generate_username(name)
    user = User.find_or_initialize_by(username: username)
    
    if user.new_record?
      user.password = "password123"
      user.password_confirmation = "password123"
      user.admin = data[:admin] || false
      user.email = "#{username}@example.com" if user.email.blank?
      user.save!
    end
    
    # Atualizar admin se necessário
    if data[:admin] && !user.admin?
      user.update!(admin: true)
    end

    # Criar celebridades e adicionar à lista
    data[:list].each_with_index do |celebrity_name, index|
      next if celebrity_name.blank?
      
      # Limpar e normalizar o nome
      celebrity_name = celebrity_name.to_s.strip
      next if celebrity_name.blank?
      
      # Buscar case-insensitive para evitar duplicatas
      celebrity = Celebrity.where('LOWER(name) = ?', celebrity_name.downcase).first
      celebrity ||= Celebrity.create!(name: celebrity_name)
      
      # Verificar se a celebridade foi criada com sucesso
      next unless celebrity.persisted?
      
      # Se está na lista de mortes, garantir que está marcado como morto
      # Buscar case-insensitive na lista de mortes
      death_key = all_deaths.keys.find { |k| k.downcase == celebrity_name.downcase }
      if death_key
        death_info = all_deaths[death_key]
        celebrity.update!(
          is_deceased: true,
          age_at_death: death_info[:age],
          death_date: death_info[:date],
          points: death_info[:points]
        )
      end

      # Criar player_list apenas se não existir
      PlayerList.find_or_create_by(
        user: user,
        celebrity: celebrity,
        year: year,
        position: index + 1
      )
    end

    admin_status = user.admin? ? " (ADMIN)" : ""
    puts "  ✓ User: #{name} (#{username})#{admin_status} - #{data[:list].count} celebrities, #{data[:total_points]} points"
  end

  puts "Year #{year} completed! Player lists: #{PlayerList.where(year: year).count}"
end

# ============================================================================
# DADOS DE 2023
# ============================================================================

all_deaths_2023 = {
  "Rita Lee" => { age: 75, date: "2023-05-10", points: 25 },
  "Tina Turner" => { age: 83, date: "2023-05-24", points: 17 },
  "PC Siqueira" => { age: 37, date: "2023-08-15", points: 63 },
  "Aracy Balabanian" => { age: 83, date: "2023-06-20", points: 17 }
}

players_data_2023 = {
  "RAY" => {
    username: "ray",
    list: [
      "Raul Gil", "Carlos A. Nóbrega", "Ana Maria Braga", "Ronnie Von", "Agnaldo Rayol",
      "Sérgio Reis", "Rita Lee", "Jane Fonda", "Ozzy Osbourne", "Mamma Bruschetta",
      "Leão Lobo", "Gilberto Barros", "Milton Nascimento"
    ],
    deaths: ["Rita Lee"],
    total_points: 25
  },
  "BOSZA" => {
    username: "bozsa",
    list: [
      "Silvio Santos", "Anthony Hopkins", "Al Pacino", "Boris Casoy", "Francisco Cuoco",
      "Marrone", "Laura Cardoso", "Susana Vieira", "Lima Duarte", "Ary Fontoura",
      "Tirulipa"
    ],
    deaths: [],
    total_points: 0
  },
  "RAUL" => {
    username: "raul",
    list: [
      "Tina Turner", "Carlos A. Nóbrega", "M. Schumacher", "Anitta", "Bonner",
      "Fabio Porchat", "Tom Cruise", "Didi", "Lima Duarte", "PC Siqueira"
    ],
    deaths: ["Tina Turner", "PC Siqueira"],
    total_points: 80,
    admin: true
  },
  "LUCAS BABRIKOWSKI" => {
    username: "lucas_babrikowski",
    list: [
      "Dennis Carvalho", "Chiquinho Scarpa", "M. Schumacher", "Alváro Dias", "W. Casagrande",
      "Ronaldo Esper", "Israel (Sertanejo)", "Claudia Rodrigues", "Carlos A. Nóbrega", "Boris Casoy",
      "Fernanda Montenegro"
    ],
    deaths: [],
    total_points: 0
  },
  "FELIPE" => {
    username: "felipe",
    list: [
      "Keith Richards", "Bono Vox", "Anitta", "Celso Portiolli", "Milton Nascimento",
      "Vladmir Putin", "Aracy Balabanian", "Jackie Chan", "50 Cent", "João Carlos Martins"
    ],
    deaths: ["Aracy Balabanian"],
    total_points: 17
  },
  "WILL" => {
    username: "will",
    list: [
      "Sidney Magal", "Carlos A. Nóbrega", "Silvio Santos", "Chitãozinho", "Fausto Silva (Faustão)",
      "Gilberto Gil", "Galvão Bueno", "Gilberto Barros", "Chico Buarque", "Amaury Jr."
    ],
    deaths: [],
    total_points: 0,
    admin: true
  }
}

seed_year(
  2023,
  { is_active: true, locked: true, start_date: Date.new(2023, 1, 15) },
  all_deaths_2023,
  players_data_2023
)

# ============================================================================
# DADOS DE 2025
# ============================================================================

all_deaths_2025 = {
  "Fuad Noman" => { age: 77, date: "2025-01-15", points: 23 },
  "Preta Gil" => { age: 50, date: "2025-06-15", points: 50 },
  "José Mujica" => { age: 89, date: "2025-12-20", points: 11 },
  "Ozzy Osbourne" => { age: 76, date: "2025-03-10", points: 24 },
  "Francisco Cuoco" => { age: 91, date: "2025-05-20", points: 9 },
  "Joan Plowright" => { age: 96, date: "2025-02-01", points: 4 },
  "Papa Francisco" => { age: 76, date: "2025-04-15", points: 24 }
}

players_data_2025 = {
  "Angela (Coveira)" => {
    username: "angela",
    list: [
      "Fuad Noman", "Tony Tornado", "Preta Gil", "Edgar Vivar", "Mama Bruschetta",
      "Ringo Starr", "Warren Beatty", "George W. Bush", "Laura Cardoso", "Milton Nascimento",
      "Yayoi Kusama", "Yoshiro Tosashi", "Tim Rice", "José Sarney", "Luiza Erundina",
      "José Mujica", "Cho Seungyoun", "Phil Collins", "Yoko Ono", "Mauricio de Souza"
    ],
    deaths: ["Fuad Noman", "Preta Gil", "José Mujica"],
    total_points: 84
  },
  "Ricardo (ex-Coveiro)" => {
    username: "ricardo",
    list: [
      "Michael Schumacker", "Boris Casoy", "Isabel Veloso", "Faustão", "José Mujica",
      "Claudia Rodrigues", "Marcos Oliveira", "Tony Tornado", "Datena", "Carlos Alberto",
      "Calminha", "Nino Abavanel", "Mama Bruschetta", "Preta Gil", "Sergio Reis",
      "Lima Duarte", "Tjairzinho", "Yoshino Togashi", "Ary Fontoura", "Milionário do José Rico"
    ],
    deaths: ["José Mujica", "Preta Gil"],
    total_points: 61
  },
  "RAUL (ex-Coveiro)" => {
    username: "raul",
    list: [
      "Carlos Alberto", "M Schumacker", "Tom Cruise", "Bruce Willis", "Bonner",
      "Didi", "Lima Duarte", "Bruno do Marrone", "Preta Gil", "Raul Gil",
      "Ary Fontoura", "Paul McCartney", "Roberto Carlos (Rei)", "Sergio Reis", "Faustão",
      "Susana Vieira", "Ana Maria Braga", "Emilio Surita", "José Mujica", "Casa Grande"
    ],
    deaths: ["Preta Gil", "José Mujica"],
    total_points: 61,
    admin: true
  },
  "Luan viado" => {
    username: "luan_viado",
    list: [
      "Fernanda Montenegro", "Faustão", "Lima Duarte", "Tony Tornando", "Ary Fontura",
      "Nathalia Tiberge", "Laura Cardoso", "José Sarney", "Lula", "FHC",
      "Maluf", "José Serra", "Eduardo Suplicy", "Gloria Menezes", "Preta Gil",
      "Francisco Cuoco", "Leda Nagle", "Lua Leifert", "Othan Bastos", "Steno Garcia"
    ],
    deaths: ["Preta Gil", "Francisco Cuoco"],
    total_points: 59
  },
  "WILL" => {
    username: "will",
    list: [
      "Faustão", "Volodymyr Zelensky", "Sarney", "Monark", "Alek do Zoio",
      "Pepe Mijica", "Gilberto Gil", "Schumacher", "Fuad Noman", "FHC",
      "Claudio Rodrigues", "Ozzy Osbourne", "Fernanda Montenegro", "Raul Gil", "Roberto Carlos",
      "Lima Duarte", "Carlos Alberto", "Gloria Menezes", "Isabel Veloso", "Andressa Urach"
    ],
    deaths: ["Pepe Mijica", "Fuad Noman", "Ozzy Osbourne"],
    total_points: 58,
    admin: true
  },
  "BOZSA" => {
    username: "bozsa",
    list: [
      "Lima Duarte", "Laura Cardoso", "Ary Fontoura", "Joan Plowright", "Preta Gil",
      "Ian Smith", "Claudia Rodrigues", "Francisco Cuoco", "Fernanda Montenegro", "Nathalia Timberg",
      "Barbara Eoen", "Dede Santana", "Gloria Menezes", "Tiago Leifert", "Stenio Garcia",
      "Carlos Alberto de Nóbrega", "Paulinho da Viola", "Thais Carla", "Ringo Star", "Diana Ross"
    ],
    deaths: ["Joan Plowright", "Preta Gil", "Francisco Cuoco"],
    total_points: 63
  },
  "RAY" => {
    username: "ray",
    list: [
      "Roberto Carlos", "Renan Calheiras", "Carlos Alberto", "Ozzy Osbourne", "Monark",
      "Preta Gil", "Lima Duarte", "Stenio Garcia", "Keith Richards", "Fernanda Montenegro",
      "Ben Affleck", "Mama Bruschetta", "Isabel Veloso", "FHC", "Morgan Freeman",
      "Sergio Reis", "Rod Stewart", "Sophia Loren", "Laura Cardoso", "Gloria Menezes"
    ],
    deaths: ["Ozzy Osbourne", "Preta Gil"],
    total_points: 74
  },
  "Bruno bizarro" => {
    username: "bruno_bizarro",
    list: [
      "Lula", "Bruce Willis", "Fernanda Montenegro", "Barbara Streisand", "Mick Jagger",
      "Faustão", "Toguro", "Bolsonaro", "Michael J Fox", "Christopher Lloyd",
      "Vicky Vanilla", "Preta Gil", "Jenna Fischer", "Rei Charles", "Ary Fontura",
      "Francisco Cuoco", "Celso Portiollu", "Kayky Brito", "Oruam", "Leda Nagle"
    ],
    deaths: ["Preta Gil", "Francisco Cuoco"],
    total_points: 59
  },
  "Felipe" => {
    username: "felipe",
    list: [
      "Renato Aragão", "Felipe Castanhari", "Laura Cardoso", "Lima Duarte", "Ary Fontura",
      "Preta Gil", "Gilberto Gil", "Nicolas Cage", "Paul McCartney", "Lula",
      "Phil Collins", "Celine Dion", "Rod Stewart", "Roberto Carlos (Rei)", "Madonna",
      "Ney Matogrosso", "Sérgio Reis", "Gustavo Lima", "Bolsonaro", "Moacyr Franco"
    ],
    deaths: ["Preta Gil"],
    total_points: 50
  },
  "Pixote" => {
    username: "pixote",
    list: [
      "Lula", "Suzana Vieira", "Preta Gil", "Faustão", "Simony",
      "Mauricio Kubrosly", "Fernanda Montenegro", "Bruce Willis", "Laura Cardoso", "Thais Carla",
      "Lima Duarte", "Ary Fontura", "Kabrinha", "Elton John", "Raul Gil",
      "Gordão da XJ", "Day Z", "Liluzi", "Fernando do Sorocaba", "Bolsonaro"
    ],
    deaths: ["Preta Gil"],
    total_points: 50
  },
  "Ray satanista" => {
    username: "ray_satanista",
    list: [
      "Raul Gil", "Lula", "Gloria Menezes", "Tony Ramos", "Lima Duarte",
      "Moon Taeil", "P Diddy", "JK Rowling", "Jim Carrey", "Faustão",
      "Didi", "Neil Gaiman", "Dinho Ouro Preto", "Andressa Urach", "Preta Gil",
      "Yoon Suk Yeel", "Zizi Pessi", "Joe Biden", "Leonardo Cantor", "Maiaria da Maraisa"
    ],
    deaths: ["Preta Gil"],
    total_points: 50
  },
  "Lucas aleatório" => {
    username: "lucas_aleatorio",
    list: [
      "P Diddy", "Jackie Chan", "Putin", "Biden", "Papa Francisco",
      "Aécio Neves", "Trump", "Arthur do Val", "Silas Malafaia", "RR Soares",
      "Bolsonaro", "Padre Kelmon", "Ricardo Salles", "Edir Macedo", "Valdemiro Santiago",
      "Michael Tamer", "Eduardo Bolsonaro", "Marco Feliciano", "Tarcisio", ""
    ],
    deaths: ["Papa Francisco"],
    total_points: 24
  }
}

seed_year(
  2025,
  { is_active: true, locked: true, start_date: Date.new(2025, 1, 15) },
  all_deaths_2025,
  players_data_2025
)

# ============================================================================
# DADOS DE 2024
# ============================================================================

all_deaths_2024 = {
  "Silvio Santos" => { age: 93, date: "2024-05-12", points: 7 },
  "Ary Toledo (humorista)" => { age: 87, date: "2024-08-20", points: 13 },
  "Sven-Goran Eriksson (ex-técnico da Inglaterra)" => { age: 76, date: "2024-08-26", points: 24 },
  "Cid Moreira" => { age: 97, date: "2024-09-15", points: 3 }
}

players_data_2024 = {
  "Ricardo" => {
    username: "ricardo",
    list: [
      "Arlindo Cruz", "M. Schumacher", "Carlos Alberto de Nóbrega", "Milionário (dupla do José Rico)",
      "Glória Menezes", "Marilyn Manson", "Thais Carla", "Sergio Reis", "Ary Toledo (humorista)",
      "Boris Casoy", "Marcos Oliveira (Beiçola)", "José Roberto Burnier", "Faustão",
      "Datena", "Caroline Francischini (modelo)", "Sven-Goran Eriksson (ex-técnico da Inglaterra)", "Chiquinho Scarpa",
      "Claudia Rodrigues", "Paulinho da Viola", "Silvio Santos"
    ],
    deaths: ["Ary Toledo (humorista)", "Sven-Goran Eriksson (ex-técnico da Inglaterra)", "Silvio Santos"],
    total_points: 44
  },
  "WILL" => {
    username: "will",
    list: [
      "Arlindo Cruz", "M. Schumacher", "Ozzy Osbourne", "Marcos Oliveira (beisola)",
      "Milton Nascimento", "Volodymyr Zelensky", "Alek \"do zoio\"", "Mingau",
      "Silvio Santos", "Carlos A Parreira", "Lima Duarte", "Faustão",
      "Fernanda montenegro", "Claudio Rodrigues", "Cid Moreira", "Carlos Alberto de Nobrega",
      "Zé felipe", "Lauro Cardoso", "Raul Gil", "Bruce Willis"
    ],
    deaths: ["Silvio Santos", "Cid Moreira"],
    total_points: 10,
    admin: true
  },
  "Luan viado" => {
    username: "luan_viado",
    list: [
      "Gilberto Gil", "Caetano veloso", "Maria bethania", "Lima duarte",
      "Tony torioda", "Anu Fontana", "Laura cardoso", "Nathalia timberg",
      "Cid moreira", "Silvio santos", "Fernanda montenegro", "Arlindo cruz",
      "Nando Reis", "Ana maria braga", "Pericles", "Stepon nevcessidio ????",
      "Keith richards", "Marcos olveira", "Faustao", "Claudia Rodrigues"
    ],
    deaths: ["Silvio Santos"],
    total_points: 7
  },
  "RAUL (Coveiro)" => {
    username: "raul",
    list: [
      "Carlos alberto de nobrega", "M. Schumacher", "Anitta", "Fabio Porchat",
      "Tom cruise", "Bonner", "Didi", "Lima duarte",
      "MC pipokinha", "Mc cabelinho", "Bruno do marrone", "Fausto silva",
      "Preta gil", "Fátima Pissarra", "Daniel Penin", "Raphael souza choquei",
      "Bruce willis", "Whindersoson Nunes", "Silvio santos", "Raul Gil"
    ],
    deaths: ["Silvio Santos"],
    total_points: 7,
    admin: true
  },
  "BOZSA" => {
    username: "bozsa",
    list: [
      "Ary Ventura", "Rosana Martinho", "Fernanda Montenegro", "Sophia Loren",
      "Laura Cardoso", "Tony Tornado", "Nathalia Timberg", "Mauro Mendonça",
      "Silvio Santos", "Carlos Alberto de Nobrega", "jane Fonda", "Margie Smith",
      "Yoko Ono", "Tom zé", "Christoper Loyd", "William Shatner",
      "Clint Eastwood", "Thais Carla", "Michael Caine", "Anthony Hopkins"
    ],
    deaths: ["Silvio Santos"],
    total_points: 7
  },
  "ANGELA" => {
    username: "angela",
    list: [
      "Fernanda montenegro", "Milton Nascimento", "Ozzy Osbourne", "Clint Eastwood",
      "Silvio Santos", "Mauricio de sousa", "Arlete Salles", "Junji Abe",
      "Claudia Rodrigues", "Phil collins", "Diogo Vilela", "José Sarney",
      "Laura Cardoso", "Dedé Santana", "Cyndi Layper", "Ronnie Lessa",
      "Thalles Cabral", "Paulo Kogos", "Yayoi Kusama", "JIsoo (black pink)"
    ],
    deaths: ["Silvio Santos"],
    total_points: 7
  },
  "Bruno bizarro" => {
    username: "bruno_bizarro",
    list: [
      "Ana maria braga", "Lula", "Temer", "Silvio Santos",
      "Gordão do XJ", "Bruce Willis", "Morgan Freeman", "Biden",
      "Fábio assunção", "Tais carla", "Whinderson nunes", "Ellen page",
      "Erza miller", "Andressa urach", "Casa grande", "Fernanda montenegro",
      "Alexandre Frota", "Mario antonio villa", "Michelle Obama", "Michale J Fox"
    ],
    deaths: ["Silvio Santos"],
    total_points: 7
  },
  "LUCAS BABRIKOWSKI (2.0)" => {
    username: "lucas_babrikowski",
    list: [
      "M Schumacher", "Casagrande", "Claudia rodrigues", "Julian assange",
      "Milton nascimento", "Juca Kfuze?", "Padre julio lanceloti", "Ed motta",
      "Michael j fox", "LCarlos A pereira", "Papa francisco", "Angus young",
      "Jim carrey", "Voris casoy", "Raul gil", "Amaury Jr",
      "Chiquinho Scarpa", "Denis carvano"
    ],
    deaths: [],
    total_points: 0
  },
  "RAY" => {
    username: "ray",
    list: [
      "Ozzy Osbourne", "Geraldo Luís", "Raul GIl", "Mario Frias",
      "matheus Ceará", "Simony", "Glória menezes", "Mama bruschetta",
      "Laura Cardoso", "Lima duarte", "Nathalia timberg", "Tony tornado",
      "Renato aragão", "Emerson Fittipaldi", "Bob bylan", "Ringo Starr",
      "Jair messias bolsonaro", "Robert Deniro", "Al pacino", "Ana maria Braga"
    ],
    deaths: [],
    total_points: 0
  },
  "Bruno Bacon" => {
    username: "bruno_bacon",
    list: [
      "Estenio Garcia", "Madonna", "Mel Gibson", "Carlos Alberto",
      "Mc Ian", "50 cent", "lil Wayne", "Orochi (cantor)",
      "Amado Batista", "Sergio Reis", "Maraísa (cantora)", "Morgan Freeman",
      "Brue Willis", "Joelma", "Boris Casoy", "Dinho Oro Preto",
      "Léo Dias", "Gustavo lima (e voce)", "Faustão", "Simony"
    ],
    deaths: [],
    total_points: 0
  },
  "Felipe" => {
    username: "felipe",
    list: [
      "André marques", "Dedé Santana", "Antonio Fagundes", "Carlinhos maia",
      "Steven Spielberg", "Tiger Woods", "Lebron James", "Donald Trump",
      "Charlie Sheen", "Larissa manoela", "Ana hickman", "Vladmir Putin",
      "Bono Vox", "Anitta", "Milton Nascimento", "Raphael Souza",
      "Whinderson Nunes", "Gustavo lima", "Jackie Chan", "Keith RIchards"
    ],
    deaths: [],
    total_points: 0
  }
}

seed_year(
  2024,
  { is_active: true, locked: true, start_date: Date.new(2024, 1, 15) },
  all_deaths_2024,
  players_data_2024
)

# ============================================================================
# DADOS DE 2026
# ============================================================================

GameYear.find_or_create_by(year: 2026) do |gy|
  gy.is_active = true
  gy.start_date = Date.new(2026, 1, 15)
end

# ============================================================================
# RESUMO FINAL
# ============================================================================

puts "\n" + "="*80
puts "SEED SUMMARY"
puts "="*80
puts "Total users: #{User.count}"
puts "Total celebrities: #{Celebrity.count}"
puts "Total player lists: #{PlayerList.count}"
puts "Total deaths: #{Celebrity.where(is_deceased: true).count}"
puts "Admin users: #{User.where(admin: true).pluck(:username).join(', ')}"
puts "\nPlayer lists by year:"
[2023, 2024, 2025, 2026].each do |year|
  count = PlayerList.where(year: year).count
  puts "  #{year}: #{count} lists" if count > 0
end
puts "="*80
