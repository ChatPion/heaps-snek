import hxd.Rand;
import format.png.Data;
import hxd.Key as K;

typedef Coord = { x : Int, y : Int }


class Dir {
    public final dx : Int;
    public final dy : Int;

    public function new(dx: Int, dy: Int) {
        this.dx = dx;
        this.dy = dy;
    }

    public static final UP = new Dir(0, -1);
    public static final DOWN = new Dir(0, 1);
    public static final LEFT = new Dir(-1, 0);
    public static final RIGHT = new Dir(1, 0);
}


class Main extends hxd.App {
    var bmp : h2d.Bitmap;
    
    var MAP_WIDTH : Int = 10;
    var MAP_HEIGHT : Int = 10;
    
    var TILE_SIZE : Int = 20;

    var snek : List<Coord>;

    var snek_group : h2d.TileGroup;
    var fruit_group : h2d.TileGroup;

    var tiles : Array<h2d.Tile.Tile>;

    var food_pos : List<Coord>;

    var rand : Rand;

    override function init() {
        super.init();

        rand = new Rand(Date.now().getSeconds() * Date.now().getMinutes());

        hxd.Res.initEmbed();

        var tile = hxd.Res.tileset.toTile();

        var group = new h2d.TileGroup(tile, s2d);
        
        tiles = [
            for (x in 0 ... 4) 
                tile.sub(x, 0, 1, 1)
        ];

        for (tile in tiles)
            tile.scaleToSize(TILE_SIZE, TILE_SIZE);

        for (x in 0 ... MAP_WIDTH)
            for (y in 0 ... MAP_HEIGHT)
                group.add(x * TILE_SIZE, y * TILE_SIZE, tiles[3]);

        fruit_group = new h2d.TileGroup(tile, s2d);
        snek_group = new h2d.TileGroup(tile, s2d);

        food_pos = new List<Coord>();

        snek = new List<Coord>();
        snek.push({x: 0, y: 0});

        draw_fruits();
        draw_snek();
    }

    function draw_snek() {
        snek_group.clear();

        for (coord in snek) {
            snek_group.add(coord.x * TILE_SIZE, coord.y * TILE_SIZE, tiles[1]);
        }

        snek_group.add(snek.last().x * TILE_SIZE, snek.last().y * TILE_SIZE, tiles[0]);
    }

    function draw_fruits() {
        fruit_group.clear();

        for (fruit in food_pos) {
            fruit_group.add(fruit.x * TILE_SIZE, fruit.y * TILE_SIZE, tiles[2]);
        }
    }

    var timer: Float = 0.0;
    var snek_dir = Dir.DOWN;
    var fruit_timer: Float = 1.0;

    function is_coord_valid(c: Coord) : Bool {
        return c.x >= 0 && c.x < MAP_WIDTH && c.y >= 0 && c.y < MAP_HEIGHT;
    }

    /**
     * Update snek
     * @return Bool Whether snek is dead or not
     */
    function update_snek() : Bool {
        var head = snek.last();
        var new_head = {x: head.x + snek_dir.dx, y: head.y + snek_dir.dy};
        if (!is_coord_valid(new_head))
            return true;

        if (Lambda.exists(snek, (c) -> c.x == new_head.x && c.y == new_head.y))
            return true;

        snek.add(new_head);

        if (!Lambda.exists(food_pos, (food) -> food.x == new_head.x && food.y == new_head.y))
            snek.pop();

        return false;
    }

    var dead : Bool = false;

    function is_not_opposite_dir(c: Dir) {
        return !(c.dx == -snek_dir.dx && c.dy == -snek_dir.dy);
    }

    override function update(dt: Float) {
        timer += dt;
        fruit_timer -= dt;

        var new_dir = snek_dir;
        if (K.isDown(K.UP))
            new_dir = Dir.UP;
        if (K.isDown(K.DOWN))
            new_dir = Dir.DOWN;
        if (K.isDown(K.LEFT))
            new_dir = Dir.LEFT;
        if (K.isDown(K.RIGHT))
            new_dir = Dir.RIGHT;
        
        if (is_not_opposite_dir(new_dir))
            snek_dir = new_dir;

        var threshold = 0.3;
        if (timer < threshold)
            return;

        timer -= threshold;

        dead = update_snek();
        
        if (dead)
            trace("I'm a ded snek");

        if (fruit_timer < 0) {
            fruit_timer = 1 + rand.random(5);
            food_pos.add({x: rand.random(MAP_WIDTH), y: rand.random(MAP_HEIGHT)});
        }

        draw_fruits();
        draw_snek();
    }

    static function main() {
        new Main();
    }
}
