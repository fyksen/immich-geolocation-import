from flask import Flask, render_template, request, redirect, url_for, session, flash
import os
import glob
import requests
import shutil

app = Flask(__name__)

app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'a_default_key_for_local_development'

SOURCE_DIR = "/app/source"
DESTINATION_DIR = "/app/destination"

def get_geolocation_from_address(address):
    try:
        base_url = "https://nominatim.openstreetmap.org/search"
        params = {
            'q': address,
            'format': 'json'
        }
        response = requests.get(base_url, params=params)
        locations = response.json()

        if not locations:
            print(f"No geolocation found for address: {address}")
            return None

        # Return full address (display_name), latitude, and longitude
        return locations[0]['display_name'], locations[0]['lat'], locations[0]['lon']
    except Exception as e:
        print(f"Error getting geolocation for address {address}. Error: {e}")
        return None

def set_geolocation_to_image(filepath, lat, lon):
    try:
        command = f'exiftool -GPSLatitude="{lat}" -GPSLongitude="{lon}" -overwrite_original "{filepath}"'
        os.system(command)
    except Exception as e:
        print(f"Error setting geolocation to image {filepath}. Error: {e}")

@app.route('/', methods=["GET", "POST"])
def index():
    if request.method == "POST":
        address = request.form.get("address")
        selected_dirs = request.form.getlist("dirs")
        session['selected_dirs'] = selected_dirs

        if address:
            geolocation = get_geolocation_from_address(address)
            if geolocation:
                session['geolocation'] = geolocation
                osm_address, lat, lon = geolocation
                session['confirmed_address'] = True
                return render_template("confirm_address.html", osm_address=osm_address, lat=lat, lon=lon)
            else:
                print(f"No geolocation found for address: {address}")
        else:
            return redirect(url_for('import_files'))

    directories = [(d, len(glob.glob(os.path.join(SOURCE_DIR, d, "*")))) for d in sorted(os.listdir(SOURCE_DIR))]
    return render_template("index.html", directories=directories)

@app.route('/import_files', methods=["GET", "POST"])
def import_files():
    if request.method == "GET" or 'confirmed_address' not in session:
        geolocation = None
    else:
        geolocation = ("User-selected location", request.form.get("lat"), request.form.get("lon"))

    selected_dirs = session.get('selected_dirs')

    if selected_dirs:
        for dir in selected_dirs:
            filepaths = glob.glob(os.path.join(SOURCE_DIR, dir, "*"))
            for filepath in filepaths:
                print(f"Processing file: {filepath}")
                dest_filepath = os.path.join(DESTINATION_DIR, os.path.basename(filepath))
                shutil.copy(filepath, dest_filepath)

                if geolocation:
                    _, lat, lon = geolocation
                    set_geolocation_to_image(dest_filepath, lat, lon)

        session.pop('geolocation', None)
        session.pop('selected_dirs', None)
        session.pop('confirmed_address', None)
        flash('Photos imported successfully!', 'success')
    return redirect(url_for('index'))


if __name__ == "__main__":
    app.run(debug=True)
