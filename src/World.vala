/* ******************************************************************************
 *# MIT License
 *
 * Copyright (c) 2015-2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
namespace Entitas {	
    /**
	 * A world manages the lifecycle of entities and groups.
     * You can create and destroy entities and get groups of entities.
	 */
	public class World : Object {
		/**
		 * A unique sequential index number assigned to each entity
		 * type int 
		 */
		public int id = 0;

		/**
		 * Pool of prebuilt entities
		 * type Entity[] 
		 */
		public Entity[] pool;

		/**
		 * Systems to run
		 * type ISystem[] 
		 */
		//  public ISystem[] systems;
		public System[] systems;

		/**
		 * Cache of unused Entity* in poool
		 * type Queue<Entity*>[] 
		 */
		public Stack<Entity*>[] cache;

		/**
		 * List of active groups
		 * type List<Group> 
		 */
		public List<Group> groups;

        /**
         * Subscribe to Entity Created Event
         * type Event.WorldChanged 
		 */
		public Event.WorldChanged onEntityCreated;

        /**
         * Subscribe to Entity Will Be Destroyed Event
         * type Event.WorldChanged 
		 */
		public Event.WorldChanged onEntityWillBeDestroyed;

        /**
         * Subscribe to Entity Destroyed Event
         * type Event.WorldChanged 
		 */
		public Event.WorldChanged onEntityDestroyed;

        /**
         * Subscribe to Group Created Event
         * type Event.GroupsChanged 
		 */
		public Event.GroupsChanged onGroupCreated;

		public World() {
			systems = new System[0];
            onGroupCreated = new Event.GroupsChanged();
            onEntityCreated = new Event.WorldChanged();
            onEntityDestroyed = new Event.WorldChanged();
            onEntityWillBeDestroyed = new Event.WorldChanged();
		}

		public void setPool(int size, int count, Buffer[] buffers) {
			pool = new Entity[size+1];
			cache = new Stack<Entity*>[count];
			for (var i = 0; i < buffers.length; i++) {
				var bufferPool = buffers[i].pool;
				var bufferSize = buffers[i].size;
				cache[bufferPool] = new Stack<Entity*>(bufferSize); 
				for (var k = 0; k < bufferSize; k++) {
					cache[bufferPool].Push(buffers[i].Factory());
				}
			}
		}
				
        /**
         * add System
         * @param system to add
         * @return this world
         */
		public World addSystem(System system) {
			// make a local copy of the array
			// so we can copy and concat

			var sy = systems;
			sy += system;//.ISystem;
			systems = sy;
			return this;
		}

        /**
         * Initialize Systems
         */
		public void initialize() {
			foreach (var system in systems)
				system.initialize();
		}

        /**
         * Update Systems
         */
		public void update(float delta) {
			foreach (var system in systems)
				system.update(delta);
		}

        /**
         * Draw Systems
         */
		public void draw() {
			foreach (var system in systems)
				system.draw();
		}

        /**
         * @param entity that was updated
         * @param index of component
         * @param component that was added or removed
         */
		public void componentAddedOrRemoved(Entity* entity, int index, void* component) {
			foreach (var group in groups)
				group.handleEntity(entity, index, component);
		}

        /**
         * Destroy an entity
         * @param entity entity
         */
		public void deleteEntity(Entity* entity) {
            onEntityWillBeDestroyed.dispatch(this, entity);
			entity.dispose();
            onEntityDestroyed.dispatch(this, entity);
			cache[entity.pool].Push(entity);

			//EntityRemoved(entity);
		}

		public void onEntityReleased(Entity* e) {

		}

		public void onComponentReplaced(Entity* e, int index,  void* component, void* replacement) {

		}

        /**
         * Create a new entity
         * @param name of entity
         * @return entity
         */
		public Entity* createEntity(string name, int pool, bool active) {
			id++;
			this.pool[id] = Entity(id, componentAddedOrRemoved, onEntityReleased, onComponentReplaced);
			return this.pool[id]
				.setName(name)
				.setPool(pool)
				.setActive(active);
		}


       /**
         * Gets all of the entities that match
         *
         * @param matcher to select for
         * @return the group
         */
 		public Group getGroup(Matcher matcher) {
			if (groups.Length() > matcher.id ) {
				return groups.Item(matcher.id).data;
			} 
			else {
				//  groups.prepend(new Group(matcher));
				groups.Insert(new Group(matcher));
				for (var i = 0; i < id-1; i++) 
					groups.Head.data.handleEntitySilently(&pool[i]);
                onGroupCreated.dispatch(this, groups.Head.data);
				return groups.Head.data;
			}
		}
	}
}


