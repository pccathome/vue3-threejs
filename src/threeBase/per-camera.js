import * as THREE from 'three'
import { useSizes } from './sizes'
export const usePerCamera = () => {
    const { sizes } = useSizes()
    const camera = new THREE.PerspectiveCamera(45, sizes.width / sizes.height, 0.1, 1000)
    return { camera }
}
