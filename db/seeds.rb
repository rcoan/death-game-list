# Skip seeding in production if 2025 data already exists
if Rails.env.production?
  if PlayerList.where(year: 2025).exists?
    puts "2025 data already exists in production. Skipping seeds."
    exit
  end
end

# Only clear data in development
if Rails.env.development?
  PlayerList.destroy_all
  Celebrity.destroy_all
  User.destroy_all
  GameYear.destroy_all
end

# Criar anos padrão
GameYear.find_or_create_by(year: 2025) do |gy|
  gy.is_active = true
end

GameYear.find_or_create_by(year: 2026) do |gy|
  gy.is_active = true
end

puts "Game years created: 2025, 2026"

# Dados de 2025 baseados nos exemplos
year_2025 = 2025

# Mapeamento de todas as mortes encontradas nos exemplos
all_deaths = {
  "Fuad Noman" => { age: 77, date: "2025-01-15", points: 23 },
  "Preta Gil" => { age: 50, date: "2025-06-15", points: 50 },
  "José Mujica" => { age: 89, date: "2025-12-20", points: 11 },
  "Ozzy Osbourne" => { age: 76, date: "2025-03-10", points: 24 },
  "Francisco Cuoco" => { age: 91, date: "2025-05-20", points: 9 },
  "Joan Plowright" => { age: 96, date: "2025-02-01", points: 4 },
  "Papa Francisco" => { age: 76, date: "2025-04-15", points: 24 }
}

# Helper to generate username from name
def generate_username(name)
  name.downcase
     .gsub(/[^a-z0-9]/, '_')
     .gsub(/_+/, '_')
     .gsub(/^_|_$/, '')
end

# Criar usuários/jogadores
players_data = {
  "Angela" => {
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
  "Ricardo (Coveiro)" => {
    username: "ricardo_coveiro",
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
    username: "raul_ex_coveiro",
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

# Criar todas as celebridades mortas primeiro
all_deaths.each do |name, death_info|
  Celebrity.find_or_create_by(name: name) do |c|
    c.is_deceased = true
    c.age_at_death = death_info[:age]
    c.death_date = death_info[:date]
    c.points = death_info[:points]
  end
end

# Criar usuários e suas listas
players_data.each do |name, data|
  username = data[:username] || generate_username(name)
  user = User.find_or_create_by(username: username) do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.admin = data[:admin] || false
  end
  
  # Atualizar admin se necessário
  if data[:admin] && !user.admin?
    user.update!(admin: true)
  end

  # Criar celebridades e adicionar à lista
  data[:list].each_with_index do |celebrity_name, index|
    next if celebrity_name.blank?
    
    celebrity = Celebrity.find_or_create_by(name: celebrity_name)
    
    # Se está na lista de mortes, garantir que está marcado como morto
    if all_deaths[celebrity_name]
      death_info = all_deaths[celebrity_name]
      celebrity.update!(
        is_deceased: true,
        age_at_death: death_info[:age],
        death_date: death_info[:date],
        points: death_info[:points]
      )
    end

    # Criar player_list
    PlayerList.find_or_create_by(
      user: user,
      celebrity: celebrity,
      year: year_2025,
      position: index + 1
    )
  end

  admin_status = user.admin? ? " (ADMIN)" : ""
  puts "Created user: #{name} (#{username})#{admin_status} with #{data[:list].count} celebrities, #{data[:total_points]} points"
end

puts "\nSeed completed! Created #{User.count} users, #{Celebrity.count} celebrities, #{PlayerList.count} player lists for year #{year_2025}"
puts "Total deaths: #{Celebrity.where(is_deceased: true).count}"
puts "Admin users: #{User.where(admin: true).pluck(:username).join(', ')}"
