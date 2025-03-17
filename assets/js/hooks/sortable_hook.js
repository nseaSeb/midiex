import Sortable from '../../vendor/sortable';
const SortableHook = {
    // This function runs when the element has been added to the DOM and its server LiveView has finished mounting
    mounted() {
        let sorter = new Sortable(this.el, {
            animation: 150,
            delay: 100,
            dragClass: 'drag-item',
            ghostClass: 'drag-ghost',
            forceFallback: true,
            onEnd: (e) => {
                let params = { old: e.oldIndex, new: e.newIndex, ...e.item.dataset };
                this.pushEventTo(this.el, 'reposition', params);
            },
        });
    },

    // This function runs when the element is about to be updated in the DOM. Note: any call here must be synchronous as the operation cannot be deferred or cancelled.
    beforeUpdate() {},

    // This function runs when the element has been updated in the DOM by the server
    updated() {},

    // This function runs when the element has been removed from the page, either by a parent update, or by the parent being removed entirely
    destroyed() {},

    // This function runs when the element's parent LiveView has disconnected from the server
    disconnected() {},

    // This function runs when the element's parent LiveView has reconnected to the server
    reconnected() {},
};

export default SortableHook;
