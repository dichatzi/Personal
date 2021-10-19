import requests
from bs4 import BeautifulSoup
import pandas as pd


"""
 All Players 
"""
alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
            "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

player_data = []

for letter in alphabet:
    url = "https://www.basketball-reference.com/players/" + letter + "/"

    response = requests.get(url=url)

    # Scrap response
    soup = BeautifulSoup(response.text, "html.parser")

    # Find players
    players = soup.find("table", {"id": "players"})
    player_rows = players.findAll("tr")

    for r in range(len(player_rows)):
        header = player_rows[r].findAll("th")

        if len(header) == 1:
            player_name = player_rows[r].find("th").getText()
            player_link = player_rows[r].find("a").get("href")

            try:
                player_data.append([player_name, player_link])
            except:
                # reason = game_rows[r].find("td", {"data-stat": "reason"}).getText()
                print("Error")

players = pd.DataFrame(data=player_data, columns=["playerName", "playerLink"])


"""
 Get Season Averages
"""


for p in range(len(players)):
    player_name = players["playerName"].iloc[p]
    player_link = players["playerLink"].iloc[p]

    # Print name to supervise current status
    print("Scrapping: " + player_name)

    # Initialize data
    final_data = []

    # Set url
    url = "https://www.basketball-reference.com" + player_link

    # Send request
    try:
        response = requests.get(url=url)

        # Scrap response
        soup = BeautifulSoup(response.text, "html.parser")

        # Find player Per Game table
        per_game_stats = soup.find("table", {"id": "per_game"})

        # Find all seasons data
        seasons = per_game_stats.findAll("tr")
        total_seasons = len(seasons) - 2

        # Find current season data
        for s in range(1, total_seasons+1):
            current_season = seasons[s]

            # Find data
            data = dict()

            season = current_season.find("th", {"data-stat": "season"}).getText()

            data["Age"] = current_season.find("td", {"data-stat": "age"}).getText()
            data["Tm"] = current_season.find("td", {"data-stat": "team_id"}).getText()
            data["Lg"] = current_season.find("td", {"data-stat": "lg_id"}).getText()
            data["Pos"] = current_season.find("td", {"data-stat": "pos"}).getText()
            data["G"] = current_season.find("td", {"data-stat": "g"}).getText()
            data["GS"] = current_season.find("td", {"data-stat": "gs"}).getText()
            data["MP"] = current_season.find("td", {"data-stat": "mp_per_g"}).getText()
            data["FG"] = current_season.find("td", {"data-stat": "fg_per_g"}).getText()
            data["FGA"] = current_season.find("td", {"data-stat": "fga_per_g"}).getText()
            data["FGpct"] = current_season.find("td", {"data-stat": "fg_pct"}).getText()
            data["3P"] = current_season.find("td", {"data-stat": "fg3_per_g"}).getText()
            data["3PA"] = current_season.find("td", {"data-stat": "fg3a_per_g"}).getText()
            data["3Ppct"] = current_season.find("td", {"data-stat": "fg3_pct"}).getText()
            data["2P"] = current_season.find("td", {"data-stat": "fg2_per_g"}).getText()
            data["2PA"] = current_season.find("td", {"data-stat": "fg2a_per_g"}).getText()
            data["2Ppct"] = current_season.find("td", {"data-stat": "fg2_pct"}).getText()
            data["eFGpct"] = current_season.find("td", {"data-stat": "efg_pct"}).getText()
            data["FT"] = current_season.find("td", {"data-stat": "ft_per_g"}).getText()
            data["FTA"] = current_season.find("td", {"data-stat": "fta_per_g"}).getText()
            data["FTpct"] = current_season.find("td", {"data-stat": "ft_pct"}).getText()

            row_data = [player_name, season]
            for key in data:
                row_data.append(data[key])

            final_data.append(row_data)
    except:
        print("No data for player " + player_name)



# Create dataframe
column_names = ["playerName", "season", "age", "team", "league", "position", "games", "gamesStarted", "minutesPlayed",
                "fieldGoals", "fieldGoalsAttempted", "fieldGoalsPercentage", "3point", "3pointAttempted", "3pointPercentage"
                "2point", "2pointAttempted", "2pointPercentage", "effectiveFieldGoalsPercentage",
                "freeThrows", "freeThrowsAttempted", "freeThrowsPercentage"]
player_stats = pd.DataFrame(data=final_data)
print(player_stats)


"""
 Season Log
"""
url = "https://www.basketball-reference.com/players/a/antetgi01/gamelog/2021"

response = requests.get(url=url)

# Scrap response
soup = BeautifulSoup(response.text, "html.parser")

# Find player Per Game table
regular_season_stats = soup.find("table", {"id": "pgl_basic"})

game_rows = regular_season_stats.findAll("tr")

for r in range(len(game_rows)):
    header = game_rows[r].findAll("th")

    if len(header) == 1:
        date_game = game_rows[r].find("td", {"data-stat": "date_game"}).getText()

        try:
            pts = game_rows[r].find("td", {"data-stat": "pts"}).getText()
            print(date_game + " --- " + pts + " points")
        except:
            reason = game_rows[r].find("td", {"data-stat": "reason"}).getText()
            print(date_game + " " + reason)


