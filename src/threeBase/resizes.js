import { useSizes } from './sizes'
import { useRenderer } from './renderer'
export const useRsize = () => {
    const resizes = () => {
        const { sizes } = useSizes()
        const { renderer } = useRenderer()
        //Update sizes
        window.addEventListener('resize', () => {
            // Update camera
            camera.aspect = sizes.width / sizes.height
            camera.updateProjectionMatrix()

            // Update renderer
            renderer.setSize(sizes.width, sizes.height)
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
        })
    }

    return { resizes }
}
