import { onMounted, onUnmounted, ref, reactive } from 'vue'
export const useSizes = () => {
    const sizes = {
        width: window.innerWidth,
        height: window.innerHeight
    }

    return { sizes }
}
