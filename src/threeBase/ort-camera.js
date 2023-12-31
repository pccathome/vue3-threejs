import * as THREE from 'three'
import { useSizes } from './sizes'
export const useOrtCamera = () => {
    const { sizes } = useSizes()
    let frustumSize = 1
    const camera = new THREE.OrthographicCamera(
        frustumSize / -2,
        frustumSize / 2,
        frustumSize / 2,
        frustumSize / -2,
        0.1,
        1000
    )
    // const camera = new THREE.OrthographicCamera(0, 1, 1, 0, 0.1, 1000)
    camera.position.set(0, 0, 1)
    return { camera }
}
