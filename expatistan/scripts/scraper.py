import requests
import re
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
from typing import Literal
import json

expatistan_countries = ['Albania', 'Algeria', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 
                  'Bangladesh', 'Belarus', 'Belgium', 'Bolivia', 'Bosnia And Herzegovina', 'Brazil', 
                  'Bulgaria', 'Canada', 'Chile', 'China', 'Colombia', 'Costa Rica', 'Croatia', 'Cyprus',
                    'Czech Republic', 'Denmark', 'Dominican Republic', 'Ecuador', 'Egypt', 'Estonia', 
                    'Finland', 'France', 'Georgia', 'Germany', 'Greece', 'Guatemala', 'Hong Kong', 
                    'Hungary', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 
                    'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kosovo', 'Kuwait', 'Latvia', 
                    'Lithuania', 'Luxembourg', 'Malaysia', 'Malta', 'Mauritius', 'Mexico', 'Montenegro', 
                    'Morocco', 'Nepal', 'Netherlands', 'New Zealand', 'Macedonia', 'Norway', 'Oman', 
                    'Pakistan', 'Panama', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Puerto Rico', 
                    'Qatar', 'Romania', 'Russia', 'Saudi Arabia', 'Serbia', 'Singapore', 'Slovakia', 
                    'Slovenia', 'South Africa', 'South Korea', 'Spain', 'Sri Lanka', 'Sweden', 
                    'Switzerland', 'Syria', 'Taiwan', 'Thailand', 'Tunisia', 'Turkey', 'Ukraine', 
                    'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan', 
                    'Venezuela', 'Vietnam']


with open('./auxiliares/item2category_expatistan.json','r') as f:
    item2category = json.load(f)

with open('./auxiliares/item2custom_category.json','r') as f:
    item2custom_category = json.load(f)

item2custom_category = {item['item_names']: item['categoria_propia'] for item in item2custom_category}


def normalize_country(country:str)->str:
    return country.lower().replace(" ","-")

def make_url(country:str, language:Literal["en",'es']='es')->str: 
    cost_living_str = "costo-de-vida"
    country_str = "pais"
    url = f"https://www.expatistan.com/{language}/{cost_living_str}/{country_str}/{country}"

    if language == "en":
        cost_living_str = "cost-of-living"
        country_str = "country"
        url = f"https://www.expatistan.com/{cost_living_str}/{country_str}/{country}"

    if country not in ["united-states", "ecuador", "puerto-rico","venezuela"]:
        url = url + "?currency=USD"
    
    print(url)
    return url

def get_soup(url:str)->BeautifulSoup:
    try:
        r = requests.get(url)
        soup = BeautifulSoup(r.content,'html.parser')
        return soup
    except requests.exceptions.HTTPError as errh:
        print ("Http Error:",errh)
    except requests.exceptions.ConnectionError as errc:
        print ("Error Connecting:",errc)
    except requests.exceptions.Timeout as errt:
        print ("Timeout Error:",errt)
    except requests.exceptions.RequestException as err:
        print ("OOps: Something Else",err)

def detect_currencies(soup_obj:BeautifulSoup)->str:
    table = soup_obj.find('table', class_="comparison single-city")
    return table.find_all("tr")[1].get_text()[1:-1].split("\n")

def get_items(soup_obj:BeautifulSoup)->list:
    item_names = soup_obj.findAll("td", class_="item-name")
    return [x.text.replace("\n","").rstrip().lstrip() for x in item_names]

def clean_prices(price)->float:
    price = price.strip().lower()
    if price == "-":
        return np.nan
    price = price.replace("(","").replace(")","").replace("$","").replace(",","")
    pattern = r'[^-0-9.,]'
    price = re.sub(pattern, "", price).strip().lstrip(".").rstrip(".")
    return float(price)

def get_prices(soup_obj:BeautifulSoup)->list:
    item_prices = soup_obj.findAll("td", class_="price city-1")
    item_prices = [x.text.replace("\n","").rstrip().lstrip() for x in item_prices]
    item_prices_loc_curr = item_prices[::2]
    item_prices_loc_curr = [clean_prices(p) for p in item_prices_loc_curr]
    item_prices_usd = item_prices[1::2]
    item_prices_usd = [clean_prices(p) for p in item_prices_usd]
    return item_prices_loc_curr, item_prices_usd

def get_prices_for_US(soup_obj:BeautifulSoup)->list:
    item_prices = soup_obj.findAll("td", class_="price city-1")
    item_prices = [x.text.replace("\n","").rstrip().lstrip() for x in item_prices]
    item_prices = [clean_prices(p) for p in item_prices]
    return item_prices

def is_consistent(list_to_check:list)->bool:
    return len(list_to_check) == 51

def make_df(country:str, item_names:list, item_prices_loc_curr:list, item_prices_usd:list)->pd.DataFrame:
    namesOK, prices_locOK, prices_usdOK = is_consistent(list_to_check=item_names), is_consistent(item_prices_loc_curr), is_consistent(item_prices_usd)
    if all( (namesOK, prices_locOK, prices_usdOK) ):
        return pd.DataFrame(
            {
                'country' : [country] * len(item_names),
                'category': [item2category[i] for i in item_names],
                'item_names': item_names,
                'item_prices_local_curr': item_prices_loc_curr,
                'item_prices_usd': item_prices_usd
                
            }
        )
    else:
        raise ValueError(f"{country} -  item_names: {len(item_names)}, item_prices_loc_curr: {len(item_prices_loc_curr)}, item_prices_usd: {len(item_prices_usd)}")

def make_df_for_US(country:str, item_names:list, item_prices)->pd.DataFrame:
    namesOK, pricesOK = is_consistent(list_to_check=item_names), is_consistent(item_prices)
    if all( (namesOK, pricesOK) ):
        return pd.DataFrame(
            {
                'country' : [country] * len(item_names),
                'category': [item2category[i] for i in item_names],
                'item_names': item_names,
                'item_prices_local_curr': item_prices,
                'item_prices_usd': item_prices
                
            }
        )
    else:
        raise ValueError(f"{country} -  item_names: {len(item_names)}, item_prices: {len(item_prices)}")

def scraping_expatistan(country:str, language:Literal['es','en'] = 'es')->pd.DataFrame:
    country_name = country
    
    country = normalize_country(country=country_name)
    url = make_url(country=country, language=language)
    soup = get_soup(url=url)
    item_names = get_items(soup_obj=soup)
    if country not in ["united-states", "ecuador", "puerto-rico","venezuela"]:
        item_prices_loc_curr, item_prices_usd = get_prices(soup_obj=soup)
        df = make_df(country=country_name, item_names=item_names, item_prices_loc_curr=item_prices_loc_curr, item_prices_usd=item_prices_usd)
    else:
        item_prices = get_prices_for_US(soup_obj=soup)
        df = make_df_for_US(country=country_name, item_names=item_names, item_prices=item_prices)
    return df


def get_expatistan_data(country_list:list[str] = expatistan_countries, cat_prop:bool = False, mapper:dict = item2custom_category)->pd.DataFrame:
    data = pd.DataFrame()
    
    for country in country_list:
        try: 
            df = scraping_expatistan(country=country, language='en')
            
            if cat_prop:
                df['categoria_propia'] = df['item_names'].map(mapper)

            data = pd.concat([data, df], axis=0)
        except Exception as e:
            print(e) 
 
    return data

