<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
// import { gsap } from 'gsap'
import backBtn from '../../components/backBtn.vue'
import footerInfo from '../../components/footerinfo.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()
scene.background = new THREE.Color('#000000')

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

camera.position.set(2, 2, 2.5)
scene.add(camera)

let planes, planeObjects, planeHelpers, object

scene.add(new THREE.AmbientLight(0xffffff, 1.5))
const dirLight = new THREE.DirectionalLight(0xffffff, 3)
dirLight.position.set(5, 10, 7.5)
scene.add(dirLight)

planes = [
    new THREE.Plane(new THREE.Vector3(-1, 0, 0), 0.56),
    new THREE.Plane(new THREE.Vector3(0, -1, 0), 0.56),
    new THREE.Plane(new THREE.Vector3(0, 0, -1), 0.56),
    new THREE.Plane(new THREE.Vector3(1, 0, 0), 0.56),
    new THREE.Plane(new THREE.Vector3(0, 1, 0), 0.56),
    new THREE.Plane(new THREE.Vector3(0, 0, 1), 0.56)
]

function createPlaneStencilGroup(geometry, plane, renderOrder) {
    const group = new THREE.Group()
    const baseMat = new THREE.MeshBasicMaterial()
    baseMat.depthWrite = false
    baseMat.depthTest = false
    baseMat.colorWrite = false
    baseMat.stencilWrite = true

    baseMat.stencilFunc = THREE.AlwaysStencilFunc

    // back faces
    const mat0 = baseMat.clone()
    mat0.side = THREE.BackSide
    mat0.clippingPlanes = [plane]
    mat0.stencilFail = THREE.IncrementWrapStencilOp
    mat0.stencilZFail = THREE.IncrementWrapStencilOp
    mat0.stencilZPass = THREE.IncrementWrapStencilOp

    const mesh0 = new THREE.Mesh(geometry, mat0)
    mesh0.renderOrder = renderOrder
    group.add(mesh0)

    // front faces
    const mat1 = baseMat.clone()
    mat1.side = THREE.FrontSide
    mat1.clippingPlanes = [plane]
    mat1.stencilFail = THREE.DecrementWrapStencilOp
    mat1.stencilZFail = THREE.DecrementWrapStencilOp
    mat1.stencilZPass = THREE.DecrementWrapStencilOp

    const mesh1 = new THREE.Mesh(geometry, mat1)
    mesh1.renderOrder = renderOrder

    group.add(mesh1)

    return group
}

planeHelpers = planes.map((p) => new THREE.PlaneHelper(p, 2, 0xffffff))
planeHelpers.forEach((ph) => {
    ph.visible = false
    scene.add(ph)
})

const geometry = new THREE.TorusKnotGeometry(0.4, 0.15, 220, 60)
object = new THREE.Group()
scene.add(object)

planeObjects = []
const planeGeom = new THREE.PlaneGeometry(4, 4)

for (let i = 0; i < 6; i++) {
    const poGroup = new THREE.Group()
    const plane = planes[i]
    const stencilGroup = createPlaneStencilGroup(geometry, plane, i + 1)

    // plane is clipped by the other clipping planes
    const planeMat = new THREE.MeshStandardMaterial({
        color: 0x770000,
        metalness: 0.1,
        roughness: 0.75,
        clippingPlanes: planes.filter((p) => p !== plane),

        clipIntersection: true,
        stencilWrite: true,
        stencilRef: 0,
        stencilFunc: THREE.NotEqualStencilFunc,
        stencilFail: THREE.ReplaceStencilOp,
        stencilZFail: THREE.ReplaceStencilOp,
        stencilZPass: THREE.ReplaceStencilOp
    })
    const po = new THREE.Mesh(planeGeom, planeMat)
    po.onAfterRender = function (renderer) {
        renderer.clearStencil()
    }

    po.renderOrder = i + 1.1

    object.add(stencilGroup)
    poGroup.add(po)
    planeObjects.push(po)
    scene.add(poGroup)
}

const material = new THREE.MeshPhysicalMaterial({
    color: 0x000000,
    metalness: 0.1,
    roughness: 0.75,
    clippingPlanes: planes,
    shadowSide: THREE.DoubleSide
})

// add the color
const clippedColorFront = new THREE.Mesh(geometry, material)
clippedColorFront.castShadow = true
clippedColorFront.renderOrder = 6
object.add(clippedColorFront)

renderer.localClippingEnabled = true

const boxG = new THREE.BoxGeometry()
const BoxObject = new THREE.Mesh(boxG, new THREE.MeshBasicMaterial())
BoxObject.scale.set(1.1, 1.1, 1.1)
const box = new THREE.BoxHelper(BoxObject)
box.material.color.setHex(0x797979)
box.material.blending = THREE.AdditiveBlending
box.material.transparent = true
scene.add(box)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const clock = new THREE.Clock()

    renderer.localClippingEnabled = true
    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = true
    controls.enabled = true
    controls.enableZoom = false

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        object.rotation.x = elapsedTime * 0.8
        object.rotation.y = elapsedTime * 0.4

        for (let i = 0; i < planeObjects.length; i++) {
            const plane = planes[i]
            const po = planeObjects[i]
            plane.coplanarPoint(po.position)
            po.lookAt(po.position.x - plane.normal.x, po.position.y - plane.normal.y, po.position.z - plane.normal.z)
        }

        controls.update()

        renderer.render(scene, camera)
        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    planes.length = 0
    planeObjects.length = 0
    scene.remove(box, dirLight, camera)
    object.remove(clippedColorFront)
    renderer.forceContextLoss()
    renderer.dispose()
    geometry.dispose()
    material.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    THREE.Cache.clear()
})
</script>

<template>
    <div class="relative h-screen w-full overflow-hidden">
        <backBtn />
        <footerInfo>
            <a href="https://threejs.org/examples/#webgl_clipping_stencil" target="_blank" class="underline-offset-2"
                >three.js webgl - clipping stencil</a
            >
        </footerInfo>
        <div class="outline-none w-full h-full z-0" ref="webgl"></div>
    </div>
</template>
