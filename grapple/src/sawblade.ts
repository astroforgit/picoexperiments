/* A blade bolted to the rock, always spinning, always deadly.
 *
 * It differs from spikes in the one way that matters to a grappling game: the
 * rope cannot survive it. Spikes are a wall you must not touch but may swing
 * from; a sawblade cuts the line, so the route past it has to be solved with
 * momentum already in hand. */
class Sawblade extends Sprite {
    constructor(x: number, y: number) {
        super({
            x: x, y: y,
            animations: [
                Animations.fromTextureList({ name: 'spin', texturePrefix: 'sawblade', textures: [0, 1, 2, 3], frameRate: 16, count: -1 }),
            ],
            defaultAnimation: 'spin',
            layer: 'entities',
            physicsGroup: 'hazards',
            // Round, unlike the square spike bounds: a blade the player passes
            // at the corner should not kill across empty tile.
            bounds: new CircleBounds(0, 0, 7),
            tags: ['deadly', 'no_grapple'],
        });
    }
}
