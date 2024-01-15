/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
    theme: {
        extend: {
            fontFamily: {
                Noto: ['Noto', 'sans-serif'],
                neue_hass_roman: ['NeueHassRoman', 'neue-hass-roman'],
                neue_hass_bold: ['NeueHassBold', 'neue-hass-bold']
            }
        }
    },
    plugins: []
}
