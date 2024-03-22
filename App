import streamlit as st
import requests
from deep_translator import GoogleTranslator
from gnews import GNews
import json
from newspaper import Article
from gtts import gTTS
import re

dict = {'english': 'en', 'afrikaans': 'af', 'albanian': 'sq', 'amharic': 'am', 'arabic': 'ar', 'armenian': 'hy', 'assamese': 'as', 'aymara': 'ay', 'azerbaijani': 'az', 'bambara': 'bm', 'basque': 'eu', 'belarusian': 'be', 'bengali': 'bn', 'bhojpuri': 'bho', 'bosnian': 'bs', 'bulgarian': 'bg', 'catalan': 'ca', 'cebuano': 'ceb', 'chichewa': 'ny', 'chinese (simplified)': 'zh-CN', 'chinese (traditional)': 'zh-TW', 'corsican': 'co', 'croatian': 'hr', 'czech': 'cs', 'danish': 'da', 'dhivehi': 'dv', 'dogri': 'doi', 'dutch': 'nl', 'esperanto': 'eo', 'estonian': 'et', 'ewe': 'ee', 'filipino': 'tl', 'finnish': 'fi', 'french': 'fr', 'frisian': 'fy', 'galician': 'gl', 'georgian': 'ka', 'german': 'de', 'greek': 'el', 'guarani': 'gn', 'gujarati': 'gu', 'haitian creole': 'ht', 'hausa': 'ha', 'hawaiian': 'haw', 'hebrew': 'iw', 'hindi': 'hi', 'hmong': 'hmn', 'hungarian': 'hu', 'icelandic': 'is', 'igbo': 'ig', 'ilocano': 'ilo', 'indonesian': 'id', 'irish': 'ga', 'italian': 'it', 'japanese': 'ja', 'javanese': 'jw', 'kannada': 'kn', 'kazakh': 'kk', 'khmer': 'km', 'kinyarwanda': 'rw', 'konkani': 'gom', 'korean': 'ko', 'krio': 'kri', 'kurdish (kurmanji)': 'ku', 'kurdish (sorani)': 'ckb', 'kyrgyz': 'ky', 'lao': 'lo', 'latin': 'la', 'latvian': 'lv', 'lingala': 'ln', 'lithuanian': 'lt', 'luganda': 'lg', 'luxembourgish': 'lb', 'macedonian': 'mk', 'maithili': 'mai', 'malagasy': 'mg', 'malay': 'ms', 'malayalam': 'ml', 'maltese': 'mt', 'maori': 'mi', 'marathi': 'mr', 'meiteilon (manipuri)': 'mni-Mtei', 'mizo': 'lus', 'mongolian': 'mn', 'myanmar': 'my', 'nepali': 'ne', 'norwegian': 'no', 'odia (oriya)': 'or', 'oromo': 'om', 'pashto': 'ps', 'persian': 'fa', 'polish': 'pl', 'portuguese': 'pt', 'punjabi': 'pa', 'quechua': 'qu', 'romanian': 'ro', 'russian': 'ru', 'samoan': 'sm', 'sanskrit': 'sa', 'scots gaelic': 'gd', 'sepedi': 'nso', 'serbian': 'sr', 'sesotho': 'st', 'shona': 'sn', 'sindhi': 'sd', 'sinhala': 'si', 'slovak': 'sk', 'slovenian': 'sl', 'somali': 'so', 'spanish': 'es', 'sundanese': 'su', 'swahili': 'sw', 'swedish': 'sv', 'tajik': 'tg', 'tamil': 'ta', 'tatar': 'tt', 'telugu': 'te', 'thai': 'th', 'tigrinya': 'ti', 'tsonga': 'ts', 'turkish': 'tr', 'turkmen': 'tk', 'twi': 'ak', 'ukrainian': 'uk', 'urdu': 'ur', 'uyghur': 'ug', 'uzbek': 'uz', 'vietnamese': 'vi', 'welsh': 'cy', 'xhosa': 'xh', 'yiddish': 'yi', 'yoruba': 'yo', 'zulu': 'zu'}

lis = []
for lan in dict.keys():
    lis.append(lan.capitalize())

API_URL = "https://api-inference.huggingface.co/models/facebook/bart-large-cnn"

headers = {"Authorization": "Bearer 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"}


def query(payload):
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()


def get_summary(st):
    output = query({
        "inputs": st,
    })
    return output[0]['summary_text']


api_url = 'https://api.apyhub.com/extract/text/webpage'
api_token = 'APY0fh7tUX9xsYI5T26fP0lC3AxBXyrUxAfOEGDh5VW3vFaTU9YO8fRIAcbbFdnTeuMN7Iv3EXzA'


def Find(string):

    regex = r"(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'\".,<>?«»“”‘’]))"
    url = re.findall(regex, string)
    return [x[0] for x in url]


def on_click():
    st.session_state.user_input = ""


st.title("NEWSFLASH")
st.header("Summarize your news with a click")

lang = st.sidebar.selectbox("Translate", lis)

text_ = st.text_area("Input your text here", height=200, key="user_input")

headers = {
    'apy-token': api_token
}
translator3 = GoogleTranslator(source='auto', target='en')
click1 = st.button('Summarize')
click2 = st.button("Clear", on_click=on_click)

from newspaper import Article

urls = Find(text_)
if(len(urls) != 0):
    article = Article(urls[0])
    article.download()
    article.parse()
    summ_text = ""
    t = article.text
    for i in range(0, len(t), 4990):
        text = t[i : i + 4990]
        url_text = translator3.translate(text)
        summ_text = summ_text + get_summary(url_text)
    if click1:
        translator = GoogleTranslator(source='auto', target=dict[lang.lower()])
        if(len(summ_text) >= 5000):
            st.write("you failed")
        summarized_text = translator.translate(summ_text)
        tts3 = gTTS(summarized_text)
        tts3.save(f"summary.mp3")
        st.write(summarized_text)
        audio_file3 = open("summary.mp3", 'rb')
        audio_bytes3 = audio_file3.read()
        st.audio(audio_bytes3, format='audio/ogg')

else:
    text2_ = translator3.translate(text_)
    done = 0
    summaries = []

    if (text_.find('Top') != -1 and text_.find('news') != -1):
        word_list = text2_.split()
        input = word_list[-1]
        google_news = GNews()

        if input.upper() in ['WORLD', 'NATION', 'BUSINESS', 'TECHNOLOGY', 'ENTERTAINMENT', 'SPORTS', 'SCIENCE', 'HEALTH', 'EDUCATION']:
            json_resp = google_news.get_news_by_topic(input.upper())
        else:
            json_resp = google_news.get_news(input)

        news_ = []

        for news in json_resp:
            article = Article(news['url'])
            news_.append(article)
        i = 1
        for new in news_:
            try:
                new.download()
                new.parse()
                translator2 = GoogleTranslator(
                    source='auto', target=dict[lang.lower()])
                summary = translator2.translate(get_summary((new.text)))
                tts = gTTS(summary)
                tts.save(f"summary{i}.mp3")
                done = 1
                summaries.append(summary)
                i += 1
                if len(summaries) == 1:
                    break

            except:
                continue


    if click1 and done:
        j = 1
        for summ in summaries:
            st.write(summ)
            audio_file = open(f"summary{j}.mp3", 'rb')
            audio_bytes = audio_file.read()
            st.audio(audio_bytes, format='audio/ogg')
            j += 1


    elif click1:
        summarized_text = get_summary(text2_)
        translator = GoogleTranslator(source='auto', target=dict[lang.lower()])
        summarized_text = translator.translate(summarized_text)
        tts2 = gTTS(summarized_text)
        tts2.save(f"summary.mp3")
        st.write(summarized_text)
        audio_file2 = open("summary.mp3", 'rb')
        audio_bytes2 = audio_file2.read()
        st.audio(audio_bytes2, format='audio/ogg')
