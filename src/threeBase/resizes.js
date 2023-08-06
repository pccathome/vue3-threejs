import { useSizes } from './sizes'
import { useRenderer } from './renderer'
export const useRsize = () => {
    const updateSize = () => {
        const { sizes } = useSizes()
        const { renderer } = useRenderer()
        //Update sizes
        sizes.width = window.innerWidth
        sizes.height = window.innerHeight

        // Update camera
        camera.aspect = sizes.width / sizes.height
        camera.updateProjectionMatrix()

        // Update renderer
        renderer.setSize(sizes.width, sizes.height)
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    }

    // window.addEventListener('resize', updateSize)

    return { updateSize }
}
