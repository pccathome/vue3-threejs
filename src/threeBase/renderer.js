import * as THREE from 'three'
import { useSizes } from './sizes'
export const useRenderer = () => {
    const { sizes } = useSizes()
    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true })
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    return { renderer }
}
