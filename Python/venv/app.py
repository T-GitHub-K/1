import streamlit as st
# 環境変数にPATHを追加する必要がある。
# C:\Users\user\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0\LocalCache\local-packages\Python310\Scripts
# streamlit run c:/Users/user/mysite/1/Python/venv/app.py
import datetime
from PIL import Image

# テキスト
st.title('SAMPLE APL')
st.caption('これはSAMPLEテストアプリです。')
st.subheader('自己紹介')
st.text('Pythonに関する情報')
code = '''
import streamlit as st

st.title('SAMPLE APL')
'''
st.code(code, language='python')

# 画像 rは/がエスケープコードとして扱うのを無視させる為
image = Image.open(r'C:\Users\user\mysite\1\Python\venv\012.jpg')
st.image(image, width=200)

# 動画
video_file = open(r'C:\Users\user\mysite\1\Python\venv\file.mp4', 'rb')
video_bytes = video_file.read()
st.video(video_bytes)

with st.form(key='profile_form'):
    # テキストボックス
    name = st.text_input('名前')
    address = st.text_input('住所')

    # セレクトボックス
    age_category = st.selectbox(
        '年齢層',
        ('こども(18才未満)', '大人(18才以上)')
    )

    # ラジオボタン
    sex_category = st.radio(
        '性別',
        ('男', '女', 'その他')
    )

    # 複数選択
    hobby = st.multiselect(
        '趣味',
        ('スポーツ', '読書', 'プログラミング', 'アニメ・映画', '釣り', '料理')
    )

    # チェックボックス
    mail_subscride = st.checkbox('メールマガジンを購読する。')
    # スライダー
    height = st.slider('身長', value=164, min_value=110, max_value=210)
    # 日付
    start_date = st.date_input('開始日', datetime.date(2022, 10, 21))

    # カラービッカー
    color = st.color_picker('テーマカラー', '#00f900')

    # ボタン
    submit_btn = st.form_submit_button('送信')
    cancel_btn = st.form_submit_button('キャンセル')
    if submit_btn:
        st.text(f'ようこそ!{name}さん!{address}に書籍送りました。')
        st.text(f'年齢層：{age_category}')
        st.text(f'性別：{sex_category}')
        st.text(f'趣味：{",".join(hobby)}')
        if mail_subscride:
            st.text('メールマガジンを購読します。')
        else:
            st.text('メールマガジンを購読しません。')

        st.text(f'身長：{height}cm')
        st.text(f'開始日付：{start_date}')
